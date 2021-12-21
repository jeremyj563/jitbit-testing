<#   
.SYNOPSIS
Function that creates a docker environment for basic testing of Jitbit Helpdesk
    
.DESCRIPTION 
Builds a docker image with Jitbit HD, MSSQL for Linux, .NET 5 then runs it with the specified parameters

.PARAMETER JitbitArchive
[string] The path to the Jitbit Helpdesk .zip archive file (i.e. HelpDeskCompany.zip)

.PARAMETER MSSQLVolume
[string] The host path to mount the 'mssql/data' volume to (default: ./mssql)

.PARAMETER MSSQLPort
[string] The host port to bind MSSQL to (default: 1433)

.PARAMETER JitbitPort
[string] The host port to bind Jitbit Helpdesk to (default: 5000)

.PARAMETER DBPassword
[string] The password to use for the MSSQL 'sa' user

.PARAMETER DockerImage
[string] Name to give the docker image (and optionally a tag in the 'name:tag' format)

.NOTES   
Name: Test-JitbitHD.ps1
Author: Jeremy Johnson
Date Created: 12-20-2021
Date Updated: 12-20-2021
Version: 1.0.0

.EXAMPLE
    PS > . .\Test-JitbitHD.ps1

.EXAMPLE
    PS > Test-JitbitHD -JitbitArchive 'path/to/HelpDesk.zip' -MSSQLVolume 'where/to/store/mssql-files' -MSSQLPort '1414' -JitbitPort '8080' -DBPassword 'supersecretpassword' -DockerImage 'jitbit-mssql-linux'

.EXAMPLE
    PS > Test-JitbitHD -JitbitArchive 'path/to/HelpDesk.zip' -MSSQLVolume 'where/to/store/mssql-files' -DockerImage 'jitbit-mssql-linux'

.EXAMPLE
    PS > Test-JitbitHD -a hd.zip -v ./db -jp 8080

.EXAMPLE
    PS > Test-JitbitHD -a hd.zip
#>

function Test-JitbitHD {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias('a')]
        [string] $JitbitArchive = $null,

        [Parameter(Mandatory=$false)]
        [Alias('v')]
        [string] $MSSQLVolume = "$(pwd)/mssql",

        [Parameter(Mandatory=$false)]
        [Alias('mp')]
        [string] $MSSQLPort = '1433',

        [Parameter(Mandatory=$false)]
        [Alias('jp')]
        [string] $JitbitPort = '5000',

        [Parameter(Mandatory=$false)]
        [Alias('dp')]
        [string] $DBPassword = 'HDPassword1',

        [Parameter(Mandatory=$false)]
        [Alias('di')]
        [string] $DockerImage = 'jitbithd'
    )

    begin {
        function Test-Dependencies {
            $isDockerInstalled = Get-Command -Name 'docker' -ErrorAction SilentlyContinue
            if ($isDockerInstalled) {
                $dockerService = Get-Service -Name 'com.docker.service' -ErrorAction SilentlyContinue
                if ($dockerService.Status -ne 'Running') {
                    Write-Error -Category ResourceUnavailable -Message "Docker service is not running. Try starting it with 'net start com.docker.service'."
                    return
                }
            } else {
                Write-Error -Category ResourceUnavailable -Message "Docker is not installed! Can be installed with 'choco install -y docker-desktop'."
                return
            }
        }

        function Expand-JitbitArchive {
            param (
                [string] $JitbitArchive,
                [string] $Destination
            )
            $alreadyExists = Test-Path -Path "$Destination/HelpDeskCompany" -ErrorAction SilentlyContinue
            if (-not $alreadyExists) {
                Expand-Archive -Path $JitbitArchive -DestinationPath $Destination
            }
        }

        function Copy-JitbitConfig {
            param (
                [string] $JitbitConfig,
                [string] $Destination
            )
            Copy-Item -Path $JitbitConfig -Destination $Destination -Force
        }

        function Build-DockerImage {
            param (
                [string] $DockerImage,
                [string] $DockerfilePath
            )
            $dockerfileFound = Test-Path -Path $DockerfilePath -ErrorAction SilentlyContinue
            if ($dockerfileFound) {
                docker build --tag $DockerImage .
            } else {
                throw "Dockerfile is not in the current directory!"
            }
        }

        function Start-DockerContainer {
            param (
                [string] $DBPassword,
                [string] $JitbitPort,
                [string] $MSSQLVolume,
                [string] $MSSQLPort,
                [string] $DockerImage
            )
            docker run --detach `
                --name=jitbit-testing `
                --env 'ACCEPT_EULA=Y' `
                --env 'JITBIT_HD_PATH=/var/www/helpdesk' `
                --env 'JITBIT_DB_HOST=localhost' `
                --env 'JITBIT_DB_USER=sa' `
                --env "JITBIT_DB_PASS=$DBPassword" `
                --env "SA_PASSWORD=$DBPassword" `
                --env "ASPNETCORE_URLS=http://+:$JitbitPort" `
                --volume "$($MSSQLVolume):/var/opt/mssql/data" `
                -p "$($JitbitPort):5000" `
                -p "$($MSSQLPort):1433" `
                $DockerImage
        }
    }

    process {
        Test-Dependencies
        Expand-JitbitArchive -JitbitArchive $JitbitArchive -Destination './'
        Copy-JitbitConfig -JitbitConfig './config/*' -Destination './HelpDeskCompany/Helpdesk/'
        Build-DockerImage -DockerImage $DockerImage -DockerfilePath './Dockerfile'
    }

    end {
        Start-DockerContainer `
            -DBPassword $DBPassword `
            -JitbitPort $JitbitPort `
            -MSSQLVolume $MSSQLVolume `
            -MSSQLPort $MSSQLPort `
            -DockerImage $DockerImage
    }
}
