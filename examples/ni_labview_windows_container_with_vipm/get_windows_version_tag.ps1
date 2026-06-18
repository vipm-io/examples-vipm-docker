[CmdletBinding()]
param(
    [switch]$SetProcessEnv,
    [string]$EnvFile,
    [string]$EnvVarName = 'WINDOWS_VERSION',
    [switch]$ResolveRegistryTag,
    [string]$RegistryTagUri = 'https://mcr.microsoft.com/v2/windows/tags/list'
)

function Get-PropertyValue {
    param(
        [Parameter(Mandatory)][object]$Source,
        [Parameter(Mandatory)][string]$Name
    )

    if ($Source.PSObject.Properties.Name -contains $Name) {
        return $Source.$Name
    }

    return $null
}

function Get-WindowsVersionTag {
    $cvPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    if (-not (Test-Path $cvPath)) {
        throw "Cannot find registry path $cvPath."
    }

    $cv = Get-ItemProperty -Path $cvPath

    $major = $null
    $minor = $null
    $build = $null

    $osInfo = $null
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    }
    catch {
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    }

    if ($osInfo) {
        $versionParts = $osInfo.Version -split '\.'
        if ($versionParts.Count -ge 1) { $major = [int]$versionParts[0] }
        if ($versionParts.Count -ge 2) { $minor = [int]$versionParts[1] }
        if ($versionParts.Count -ge 3) { $build = [int]$versionParts[2] }

        if (-not $build -and $osInfo.BuildNumber) {
            $build = [int]$osInfo.BuildNumber
        }
    }

    if (($null -eq $major) -or ($null -eq $minor) -or ($null -eq $build)) {
        if ($null -eq $major) { $major = Get-PropertyValue -Source $cv -Name 'CurrentMajorVersionNumber' }
        if ($null -eq $minor) { $minor = Get-PropertyValue -Source $cv -Name 'CurrentMinorVersionNumber' }
        if ($null -eq $build) { $build = Get-PropertyValue -Source $cv -Name 'CurrentBuildNumber' }
    }

    if (($null -eq $major) -or ($null -eq $minor)) {
        $currentVersion = Get-PropertyValue -Source $cv -Name 'CurrentVersion'
        if ($currentVersion -and $currentVersion -match '^(\d+)\.(\d+)$') {
            if ($null -eq $major) { $major = [int]$Matches[1] }
            if ($null -eq $minor) { $minor = [int]$Matches[2] }
        }
    }

    if (($null -eq $major) -or ($null -eq $minor) -or ($null -eq $build)) {
        throw 'Unable to determine Windows version from available sources.'
    }

    $ubr = Get-PropertyValue -Source $cv -Name 'UBR'
    if ($null -eq $ubr) {
        $ubr = 0
    }

    $architecture = if ([Environment]::Is64BitOperatingSystem) { 'amd64' } else { 'x86' }
    return "$major.$minor.$build.$ubr-$architecture"
}

function Get-RegistryWindowsTags {
    param(
        [Parameter(Mandatory)][string]$BaseUri
    )

    $tags = @()
    $pageUri = if ($BaseUri -match '\?') { $BaseUri } else { "$BaseUri?page_size=1024" }

    while ($pageUri) {
        $response = Invoke-RestMethod -Uri $pageUri -Method Get -ErrorAction Stop
        if ($response.tags) {
            $tags += $response.tags
        }

        if ($response.next) {
            if ($response.next -match '^https?://') {
                $pageUri = $response.next
            }
            else {
                $pageUri = "https://mcr.microsoft.com$($response.next)"
            }
        }
        else {
            $pageUri = $null
        }
    }

    return $tags
}

function Select-CompatibleRegistryTag {
    param(
        [Parameter(Mandatory)][string[]]$Tags,
        [Parameter(Mandatory)][string]$HostTag
    )

    $hostParts = $HostTag -split '-'
    $hostVersion = [version]$hostParts[0]
    $hostArch = if ($hostParts.Count -gt 1) { $hostParts[1] } else { 'amd64' }
    $pattern = '^(?<version>\d+\.\d+\.\d+\.\d+)-(?<arch>amd64|x86)$'

    $candidates = foreach ($tag in $Tags) {
        if ($tag -match $pattern) {
            $arch = $Matches['arch']
            if ($arch -ne $hostArch) {
                continue
            }

            $version = [version]$Matches['version']
            if ($version -le $hostVersion) {
                [PSCustomObject]@{
                    Tag     = $tag
                    Version = $version
                }
            }
        }
    }

    $best = $candidates | Sort-Object Version -Descending | Select-Object -First 1
    return $best.Tag
}

try {
    $tag = Get-WindowsVersionTag

    if ($ResolveRegistryTag) {
        try {
            $allTags = Get-RegistryWindowsTags -BaseUri $RegistryTagUri
            $resolved = Select-CompatibleRegistryTag -Tags $allTags -HostTag $tag
            if ($resolved) {
                $tag = $resolved
            }
            else {
                Write-Warning 'Unable to find a compatible registry tag; falling back to host version.'
            }
        }
        catch {
            Write-Warning "Failed to query registry tags: $($_.Exception.Message). Using host version instead."
        }
    }
}
catch {
    Write-Error $_
    exit 1
}

if ($SetProcessEnv) {
    Set-Item -Path "Env:$EnvVarName" -Value $tag
}

if ($EnvFile) {
    if (-not (Test-Path $EnvFile)) {
        throw "Env file '$EnvFile' not found."
    }

    $pattern = "^\s*$EnvVarName\s*="
    $found = $false
    $updated = foreach ($line in Get-Content -Path $EnvFile) {
        if ($line -match $pattern) {
            $found = $true
            "$EnvVarName=$tag"
        }
        else {
            $line
        }
    }

    if (-not $found) {
        $updated += "$EnvVarName=$tag"
    }

    Set-Content -Path $EnvFile -Value $updated -Encoding UTF8
}

Write-Output $tag
