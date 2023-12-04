# Script de preparação base do SO

# Verificação de super usuário
if [ "$EUID" -ne 0 ] then
    echo "Por favor, inicie o script como super usuário (SUDO)"
    exit 
fi

# Obter o cliente
clear
echo "Digite o nome do cliente (letras maiusculas)"
read CLIENTE
CLIENTE="Hostname=PROXY"
ZabbixHost="Hostname="$CLIENTE"-PROXY"

# Criação de repositórios para o Docker
if [[ ! -e /app ]]; then 
    mkdir /app 
fi
if [[ ! -e /app/docker ]]; then 
    mkdir /app/docker
fi
if [[ ! -e /etc/docker ]]; then 
    mkdir /etc/docker 
fi

# Configuração do Docker Engine
# Referencias: https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Configuração do Zabbix Agent

# Instalação das dependencias
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update

# Instalação e configuração do Agent2
apt install zabbix-agent2 -y

# Configuração do Agent2
rm /etc/zabbix/zabbix_agent2.conf
{
    echo ''
    echo 'PidFile=/var/run/zabbix/zabbix_agent2.pid'
    echo 'LogFile=/var/log/zabbix/zabbix_agent2.log'
    echo 'LogFileSize=5'
    echo 'Server=127.0.0.1'
    echo 'ServerActive=127.0.0.1'
    echo  $CLIENTE
    echo 'Include=/etc/zabbix/zabbix_agent2.d/*.conf'
    echo 'ControlSocket=/tmp/agent.sock'
    echo 'Include=./zabbix_agent2.d/plugins.d/*.conf'
} >> /etc/zabbix/zabbix_agent2.conf

# Habilitar inicialização automática
systemctl enable zabbix-agent2.service

# Reiniciar o Agent
systemctl restart zabbix-agent2.service