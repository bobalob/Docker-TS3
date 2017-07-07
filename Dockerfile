#escape=`

FROM microsoft/windowsservercore

COPY teamspeak3.zip C:\

RUN powershell.exe -Command `
    Write-Host "Running as user: $($ENV:UserName)"; `
    Expand-Archive .\teamspeak3.zip C:\

EXPOSE 9987/udp

ENTRYPOINT powershell.exe -Command `
    Write-Host "Starting TS3" ; `
    Set-Location "C:\teamspeak3-server_win64"; `
    .\ts3server.exe ; `
    Start-Sleep 1 ; `
    $Logs = Get-ChildItem "C:\teamspeak3-server_win64\logs" ; `
    foreach ($Log in $Logs) {Get-Content $Log.fullname} ; `
    $Proc = Get-Process ts3server ; `
    $Proc ; `
    While ($Proc) { Start-Sleep 60 ; $Proc = Get-Process ts3server}