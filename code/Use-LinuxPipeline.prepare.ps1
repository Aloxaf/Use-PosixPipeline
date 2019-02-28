Push-Location $PSScriptRoot;
Add-Type -TypeDefinition (Get-Content './Use-LinuxPipeline.cs' -Encoding 'UTF8' -Raw);
Pop-Location;
