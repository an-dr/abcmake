
rm -r -force $PSScriptRoot/project/build
rm -r -force $PSScriptRoot/project_custom/build

& $PSScriptRoot/project/run.ps1
& $PSScriptRoot/project_custom/run.ps1
