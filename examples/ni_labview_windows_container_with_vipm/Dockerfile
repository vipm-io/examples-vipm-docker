# Indicates that the windowsservercore image will be used as the base image.
# see here for a list of tags: https://mcr.microsoft.com/v2/windows/tags/list
ARG  WINDOWS_VERSION="latest"
FROM mcr.microsoft.com/windows:${WINDOWS_VERSION}

RUN net accounts /maxpwage:unlimited
RUN net user Container /add /expire:never /passwordreq:no
RUN net localgroup Administrators Container /add

USER Container

# Install Chocolatey
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Download, Install and Disable Package Caching
WORKDIR /users/public/downloads
ENV NIPM_VERSION "22.5.0"
COPY ./download_nipm.ps1 .
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; .\download_nipm.ps1

RUN NIPackageManager.exe \
    --passive \
    --accept-eulas \
    --prevent-reboot \
    &&\
    del NIPackageManager.exe

# Add NI Package Manager to path, so we can always just execute 'nipkg'
RUN setx /M PATH "%PATH%;C:\Program Files\National Instruments\NI Package Manager"

# Disable Packages Cache
# https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z0000019KdtSAE&l=en-US
WORKDIR "/ProgramData/National Instruments/NI Package Manager/Settings"
RUN echo [nipkg]>>nipkg.ini &&\
    echo cachepackages=false>>nipkg.ini

# Install -- NI License Manager
ENV NILM_VERSION "21.8"
ENV NILM_FEEDNAME "ni-license-manager-21-8-released"
WORKDIR "/Program Files/National Instruments/NI Package Manager"
RUN nipkg.exe feed-add --name="%NILM_FEEDNAME%" "https://download.ni.com/support/nipkg/products/ni-l/ni-license-manager/%NILM_VERSION%/released" &&\
    nipkg.exe feed-add --name="%NILM_FEEDNAME%-critical" "https://download.ni.com/support/nipkg/products/ni-l/ni-license-manager/%NILM_VERSION%/released-critical" &&\
    nipkg.exe update &&\
    nipkg.exe install --accept-eulas --yes ni-license-manager

WORKDIR "/"