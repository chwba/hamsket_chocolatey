$ErrorActionPreference = 'Stop';

$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$local_setup_file = Join-Path $toolsDir 'hamsket_setup.exe'

$packageArgs = @{
  packageName = 'hamsket-nightly'
  file = $local_setup_file
  fileType = 'exe'
  validExitCodes = @(0)
  checksum = '9A4B8099FB402ED92D360893FC3BE8533A96F526FECA9627F9E3EAB7D8298C8F'
  checksumType = 'sha256'
}

Install-ChocolateyInstallPackage @packageArgs
