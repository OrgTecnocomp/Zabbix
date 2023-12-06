# Configuração do Zabbix Agent2
# Sistema Operacional: Baseados em CentOS 7

# Obter o Hostname
clear
echo "Digite o hostname (letras maiusculas)"
read CLIENTE
ZabbixHost="Hostname=TECNO-"$CLIENTE