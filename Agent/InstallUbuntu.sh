# Configuração do Zabbix Agent2
# Sistema Operacional: Ubuntu 22.04 LTS

clear

# Instalação das dependencias
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update

# Instalação e configuração do Agent2
apt install zabbix-agent2 -y

# Configuração do Agent2
ZabbixHost="Hostname=TECNO-"
ZabbixHost+=$HOSTNAME
rm /etc/zabbix/zabbix_agent2.conf -vf
{
    echo '# Configurações de Log'
    echo 'PidFile=/var/run/zabbix/zabbix_agent2.pid'
    echo 'LogFile=/var/log/zabbix/zabbix_agent2.log'
    echo 'LogFileSize=5'
    echo ''
    echo '# Configuração do Zabbix Server/Proxy'
    echo 'Server=20.0.0.10,10.10.1.115'
    echo 'ServerActive=20.0.0.10,10.10.1.115'
    echo $ZabbixHost   
    echo ''
    echo '# Configurações Adicionais'
    echo 'Include=/etc/zabbix/zabbix_agent2.d/*.conf'
    echo 'ControlSocket=/tmp/agent.sock'
    echo 'Include=./zabbix_agent2.d/plugins.d/*.conf'
} >> /etc/zabbix/zabbix_agent2.conf

# Habilitar inicialização automática
systemctl enable zabbix-agent2.service

# Reiniciar o Agent
systemctl restart zabbix-agent2.service

# Adicionar a regra ao firewall UFW
sudo ufw allow 10050/tcp

# Remove o lixo da instalação
rm zabbix-release_*