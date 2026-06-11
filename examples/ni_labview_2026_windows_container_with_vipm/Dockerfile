FROM nationalinstruments/labview:latest-windows

# Configure PowerShell for automated installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download and install VIPM (silent install)
RUN Invoke-WebRequest -Uri 'https://packages.jki.net/vipm/preview/vipm-setup-latest-preview.exe' -OutFile 'C:\\vipm-setup.exe' ; \
    Start-Process -Wait -FilePath 'C:\\vipm-setup.exe' -ArgumentList '/quiet', '/norestart' ; \
    Remove-Item 'C:\\vipm-setup.exe' -Force

# Add VIPM to PATH
RUN $vipmPath = 'C:\Program Files\JKI\VIPM'; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $vipmPath, 'Machine')

# Verify VIPM installation
RUN vipm --version

SHELL ["cmd", "/S", "/C"]

CMD ["powershell"]
