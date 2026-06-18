$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$DOWNLOAD_URL = "https://download.ni.com/support/nipkg/products/ni-package-manager/installers/NIPackageManager${env:NIPM_VERSION}.exe"

Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "NIPackageManager.exe"