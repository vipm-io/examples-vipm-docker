# Indicates that the windowsservercore image will be used as the base image.
# see here for a list of tags: https://mcr.microsoft.com/v2/windows/tags/list
ARG  WINDOWS_VERSION="latest"
FROM mcr.microsoft.com/windows:${WINDOWS_VERSION}

RUN net accounts /maxpwage:unlimited
RUN net user Container /add /expire:never /passwordreq:no
RUN net localgroup Administrators Container /add

USER Container

######################################
# Chocolatey Installation
######################################

RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


######################################
# NI Package Manager Installation
######################################

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


######################################
# LabVIEW Installation
######################################

# Configure Variables
ENV LABVIEW_VERSION_YEAR "2025"
ENV LABVIEW_VERSION_NUMBER "25.3"
ENV LABVIEW_RELEASED_FEED_URL "https://download.ni.com/support/nipkg/products/ni-l/ni-labview-2025/25.3/released"
ENV LABVIEW_FOLDER "C:\Program Files\National Instruments\LabVIEW 2025"
ENV LABVIEW_RELEASED_FEED_NAME "ni-labview-2025-core-en-2025 Q3-released"
ENV LABVIEW_NIPKG_NAME "ni-labview-2025-core-en"

# Download and Install LabVIEW
WORKDIR "/Program Files/National Instruments/NI Package Manager"
RUN nipkg feed-add --name="%LABVIEW_RELEASED_FEED_NAME%" "%LABVIEW_RELEASED_FEED_URL%" &&\
    nipkg feed-add --name="%LABVIEW_RELEASED_FEED_NAME%-critical" "%LABVIEW_RELEASED_FEED_URL%-critical" &&\
    nipkg update &&\
    powershell -Command New-Item ${env:LABVIEW_FOLDER} -ItemType Directory &&\
    setx /M PATH "%PATH%;C:\Program Files\National Instruments\Shared\License Manager" &&\
    nipkg install --accept-eulas --yes "%LABVIEW_NIPKG_NAME%" ni-license-manager & exit 0

# Configure LabVIEW for CI/CD and VI Server TCP access
WORKDIR "$LABVIEW_FOLDER"
COPY ./LabVIEW.ini .

######################################
# LabVIEW 2020 Runtime Installation
# (VIPM prerequisite)
######################################

ENV LV2020_RTE_FEED_NAME "ni-labview-2020-runtime-engine-2020 SP1-released"
ENV LV2020_RTE_FEED_URL "https://download.ni.com/support/nipkg/products/ni-l/ni-labview-2020-runtime-engine/20.1/released"
ENV LV2020_RTE_FEED_NAME_CRITICAL "ni-labview-2020-runtime-engine-2020 SP1-released-critical"
ENV LV2020_RTE_FEED_URL_CRITICAL "https://download.ni.com/support/nipkg/products/ni-l/ni-labview-2020-runtime-engine/20.1/released-critical"
ENV LV2020_RTE_PACKAGE "ni-labview-2020-runtime-engine"

WORKDIR "/Program Files/National Instruments/NI Package Manager"
RUN nipkg feed-add --name="%LV2020_RTE_FEED_NAME%" "%LV2020_RTE_FEED_URL%" &&\
    nipkg feed-add --name="%LV2020_RTE_FEED_NAME_CRITICAL%" "%LV2020_RTE_FEED_URL_CRITICAL%" &&\
    nipkg update &&\
    nipkg install --accept-eulas --yes %LV2020_RTE_PACKAGE% & exit 0

######################################
# VIPM Installation
######################################

RUN powershell \
    $OriginalProgress = $ProgressPreference; \
    $ProgressPreference = 'SilentlyContinue'; \
    Write-Output "Downloading VIPM installer..."; \
    Invoke-WebRequest -Uri "https://packages.jki.net/vipm/preview/vipm-setup-latest-preview.exe" -OutFile "${env:TEMP}\vipm-setup.exe"; \
    $ProgressPreference = $OriginalProgress; Write-Output "Installing VIPM silently..."; \
    Start-Process -FilePath "${env:TEMP}\vipm-setup.exe" -ArgumentList '/exenoui','/qn','/norestart' -Wait; \
    Write-Output "Cleaning up installer file..."; \
    Remove-Item "${env:TEMP}\vipm-setup.exe"; \
    Write-Output "VIPM installation completed!"

######################################
# VIPM Configuration Prerequisites
# (helps to avoid first-run issuess)
######################################

ENV JKI_PROGRAM_DATA "C:\ProgramData\JKI"
ENV VIPM_PROGRAM_DATA "C:\ProgramData\JKI\VIPM"

RUN powershell -Command "New-Item -ItemType Directory -Force -Path $env:JKI_PROGRAM_DATA"
RUN powershell -Command "New-Item -ItemType Directory -Force -Path $env:VIPM_PROGRAM_DATA"

COPY ./vipm/jki.conf "C:/ProgramData/JKI/jki.conf"
COPY ./vipm/Settings.ini "C:/ProgramData/JKI/VIPM/Settings.ini"

WORKDIR "/"