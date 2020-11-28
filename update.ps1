# Script to manually prepare an update
. .\download_file.ps1

$a = New-Object -ComObject wscript.shell
$intAnswer = $a.popup("Have you updated the version number in hamsket-nightly.nuspec?",0,"",4)
if ($intAnswer -eq 6) {
	Write-Host ""
} else {
	Write-Host "Exit."
	exit
}

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$local_setup_file = Join-Path $toolsDir '\tools\hamsket_setup.exe'
$local_setup_ignore_file = Join-Path $toolsDir '\tools\hamsket_source.zip.ignore'
$local_source_code_zip = Join-Path $toolsDir '\tools\hamsket_source.zip'
$local_source_code_zip_ignore_file = Join-Path $toolsDir '\tools\hamsket_setup.exe.ignore'
$chocolatey_install_ps1 = Join-Path $toolsDir '\tools\chocolateyinstall.ps1'
$verification_txt = Join-Path $toolsDir '\tools\VERIFICATION.txt'


try { Remove-Item $local_setup_file }
catch {}
try { Remove-Item $local_source_code_zip }
catch {}
try { Remove-Item $local_source_code_zip_ignore_file }
catch {}
try { Remove-Item $local_setup_ignore_file }
catch {}
try { Remove-Item $chocolatey_install_ps1 }
catch {}
try { Remove-Item $verification_txt }
catch {}

New-Item -Path $local_source_code_zip_ignore_file -ItemType File
New-Item -Path $local_setup_ignore_file -ItemType File

$url = "https://github.com/TheGoddessInari/hamsket/releases/download/nightly/Hamsket.Setup.0.6.1.exe"
DownloadFileWithProgress $url $local_setup_file
DownloadFileWithProgress "https://github.com/TheGoddessInari/hamsket/archive/nightly.zip" $local_source_code_zip

$sha256 = Get-FileHash $local_setup_file -Algorithm SHA256 | Select-Object -ExpandProperty "Hash"
Write-Host $sha256

$chocolateyinstall_ps1_content = @"
`$ErrorActionPreference = 'Stop';

`$toolsDir = `$(Split-Path -parent `$MyInvocation.MyCommand.Definition)
`$local_setup_file = Join-Path `$toolsDir 'hamsket_setup.exe'

`$packageArgs = @{
  packageName = 'hamsket-nightly'
  file = `$local_setup_file
  fileType = 'exe'
  validExitCodes = @(0)
  checksum = '$sha256'
  checksumType = 'sha256'
}

Install-ChocolateyInstallPackage @packageArgs
"@

$timestamp = (Get-Date).ToString("yyyy-MM-dd")
$verification_txt_content = @"
How to verify the SHA256 checksum of hamsket_setup.exe in Powershell?

`$file = "hamsket_setup.exe"
Write-Host `$file
`$sha256 = get-filehash `$file -Algorithm SHA256  | select -ExpandProperty "Hash"
Write-Host `$sha256

The checksum of the included setup executable is: $sha256
It was downloaded from $url on $timestamp.

As the software maintainer, always replaces the nightly releases without realease numbering, I have enclosed
the source code for the user in hamsket_source.zip to build the exe and verify the checksum of the generated setup theirselves as well.
"@

Out-File -FilePath $chocolatey_install_ps1 -InputObject $chocolateyinstall_ps1_content
Out-File -FilePath $verification_txt -InputObject $verification_txt_content

# Create .nupkg from .nuspec
try { Remove-Item *.nupkg }
catch {}

choco pack

Write-Host "Testing installation.."
choco install hamsket-nightly -fdv -s .
$a = New-Object -ComObject wscript.shell
$intAnswer = $a.popup("Do you want to push the new package now?",0,"",4)
if ($intAnswer -eq 6) {
	choco push
} else {
	Write-Host ""
}
