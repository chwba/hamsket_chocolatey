$ErrorActionPreference = 'Stop';

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$local_setup_file = Join-Path $toolsDir 'hamsket_setup.exe'

$packageArgs = @{
  packageName = 'hamsket-nightly'
  file = $local_setup_file
  fileType = 'exe'
  validExitCodes = @(0)
  checksum = 'DA8EB4EEC6558AD229A5955787E5E1786A42DB78C467E66E27C22B57C3A0AA91'
  checksumType = 'sha256'
}

Install-ChocolateyInstallPackage @packageArgs
