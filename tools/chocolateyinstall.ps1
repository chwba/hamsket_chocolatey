$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$local_setup_file = Join-Path $toolsDir 'hamsket_setup.exe'

$packageArgs = @{
	packageName = 'hamsket-nightly'
	softwareName = 'Hamsket*'
	file = $local_setup_file
	fileType = 'exe'
	validExitCodes = @(0)
	checksum = '8A76BEFEAE83FDD43A470DFA7074209C307C30C6C2405B1298998CF78C0104C4'
	checksumType = 'sha256'
}

Install-ChocolateyInstallPackage @packageArgs
