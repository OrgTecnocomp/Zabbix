# Elevação automática do script para Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Variáveis definidas
$zbxHost    =   $args[0]
$zbxFolder  =   "C:\Program Files\Zabbix\"
$zbxConf    =   @"
LogFile=$zbxFolder\zabbix_agent2.log
LogFileSize=5
DebugLevel=3
Server=$zbxHost
ServerActive=$zbxHost
Hostname=$env:COMPUTERNAME
ControlSocket=\\.\pipe\agent.sock
Include=.\zabbix_agent2.d\plugins.d\*.conf
"@

# Download do Zabbix Agent2 6.4
Invoke-WebRequest -OutFile $env:Temp\zabbix.zip https://cdn.zabbix.com/zabbix/binaries/stable/6.4/6.4.9/zabbix_agent2-6.4.9-windows-amd64-static.zip
New-Item -Name "Zabbix" -Path "C:\Program Files\" -ItemType Directory -ErrorAction SilentlyContinue
Expand-Archive -Path $env:Temp/zabbix.zip -DestinationPath $zbxFolder -Force
Remove-Item -Path $env:Temp\zabbix.zip

# Edição do arquivo de configuração padrão
Remove-Item -Path $zbxFolder\conf\zabbix_agent2.conf # Remoção do arquivo antigo
New-Item -Name "zabbix_agent2.conf" -Path $zbxFolder\conf -ItemType File -Value $zbxConf # Inclusão do arquivo novo

# Desliga serviços antigos
Stop-Service 'Zabbix Agent'
Stop-Service 'Zabbix Agent 2'

# Realiza a instalação do agent
Set-Location $zbxFolder\bin
.\zabbix_agent2.exe -c $zbxFolder\conf\zabbix_agent2.conf -i
Stop-Service 'Zabbix Agent 2'
Start-Service 'Zabbix Agent 2'
Pause
