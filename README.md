# Jitbit Helpdesk - Crappy Docker Build (for testing only)

- [Jitbit Helpdesk - Crappy Docker Build (for testing only)](#jitbit-helpdesk---crappy-docker-build-for-testing-only)
  - [Instructions](#instructions)
    - [Clone this repository](#clone-this-repository)
    - [Run the PowerShell script](#run-the-powershell-script)
    - [Access Jitbit](#access-jitbit)

## Instructions
Note: To use this repo it is assumed that you will be running all commands on a recent build of Windows 10 with WSL2 and Docker-Desktop properly installed, configured and running

All commands should be ran from PowerShell (instead of cmd.exe)

### Clone this repository
```
PS > git clone https://github.com/jeremyj563/jitbit-testing.git
```

### Run the PowerShell script
```
# Check the script header annotations for more usage documentation

PS ...\jitbit-testing> . .\Test-JitbitHD.ps1
PS ...\jitbit-testing> Test-JitbitHD -JitbitArchive 'path/to/HelpDesk.zip'
```

### Access Jitbit
Verify the container ran and bootstrapped successfully, then navigate in your browser to:

http://localhost:5000