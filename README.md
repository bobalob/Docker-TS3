# Installation

Install the Docker-Microsoft PackageManagement Provider from the PowerShell Gallery.

	Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Install the latest version of Docker.

    Install-Package -Name docker -ProviderName DockerMsftProvider

Restart the computer

    Restart-Computer -Force


# Running a container

Running the .net Demo image

    docker run microsoft/dotnet-samples:dotnetapp-nanoserver

Running the IIS Demo image with a port forward

    docker run -d --name test-iis -p 80:80 microsoft/iis


# Creating a container manually

Run the Windows Server Core image and install TS3

    docker run -it --name test-container -p 9987:9987/udp microsoft/windowsservercore powershell.exe
    Get-ChildItem

Open an additional command prompt

    docker cp C:\Temp\teamspeak.zip test-container:c:\

Back in the container session

    Extract-Archive C:\temp\teamspeak.zip C:\
    Set-Location C:\teamspeak3-server
    .\ts3server.exe
    Get-Childitem C:\teamspeak3-server\logs | % {Get-Content $_.FullName}

Connect to your teamspeak server! If you're in Azure you will need to open up 9987/udp in your network security group.

Save the image for redeployment

    docker commit test-container manual-ts3

# Building a container with Dockerfile

Create and save a file called Dockerfile in C:\DockerTS3 folder

### Dockerfile content:

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

The above Dockerfile does the following:

 - **FROM** uses microsoft/windowsservercore as a base image.  
 - **COPY** copies the teamspeak.zip installation file from the host to the image.
 - **RUN** unpacks the teamspeak server files
 - **EXPOSE** sets the default teamspeak server port as a default port. This means using the -P switch in **docker run** will open the port from the host.
 - **ENTRYPOINT** this sets the default command to run when a container is built from the image. This is not run when building the image, only at runtime. The powershell code starts ts3 server and then outputs the log files containing server keys to the docker log. Once running, the script goes into a loop and will automatically end (and stop the container) if the ts3server process dies.

# Build Instructions

Copy your teamspeak3 server zip file to the C:\DockerTS3 folder

Build the image

	cd C:\DockerTS3
	docker build -t dninjadave/ts3server .

Run a container based on the new image

	docker run -d -p 9987:9987/udp --name newtest-ts3 dninjadave/ts3server

Output the logs to grab the teamspeak server keys

	docker logs newtest-ts3

# Upload your new container image to Docker Hub

Login to docker hub

    docker login

Push your image

    docker push dninjadave/ts3server

Remove the local copy of your image

    docker rmi dninjadave/ts3server

Remove any old containers

    docker ps -a
    docker rm <Container ID>


# Run your cloud image from anywhere

List current images and containers

    docker images
    docker ps -a

Run the image from docker hub

    docker run -d -p 9987:9987/udp --name superts3 dninjadave/ts3server

Cache the image locally without running

    docker pull dninjadave/ts3server

List current images and containers

    docker images
    docker ps -a


# Additional options

### Environment Variables

![Kitematic General Tab](http://i.imgur.com/9Yh1hsY.png)

### Volumes

![Kitematic Volumes Tab](http://i.imgur.com/p6U1c6g.png)

### Other network options

![Kitematic Network Tab](http://i.imgur.com/VzSH9fO.png)
