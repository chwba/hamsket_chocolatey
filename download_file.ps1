$colorscheme = (Get-Host).PrivateData
$colorscheme.ProgressBackgroundColor = "blue"
$colorscheme.ProgressForegroundColor = "white"
function DownloadFileWithProgress
{
	param(
		[Parameter(Mandatory = $true)]
		[string]$url,
		[Parameter(Mandatory = $false)]
		[string]$localFile = (Join-Path $pwd.Path $url.SubString($url.LastIndexOf('/')))
	)

	begin {
		$client = New-Object System.Net.WebClient
		$client.Headers.Add('user-agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36')
		$Global:downloadComplete = $false
		$eventDataComplete = Register-ObjectEvent $client DownloadFileCompleted `
 			-SourceIdentifier WebClient.DownloadFileComplete `
 			-Action { $Global:downloadComplete = $true }
		$eventDataProgress = Register-ObjectEvent $client DownloadProgressChanged `
 			-SourceIdentifier WebClient.DownloadProgressChanged `
 			-Action { $Global:DPCEventArgs = $EventArgs }
	}
	process {
		Write-Progress -Activity 'Downloading file' -Status $url
		$client.DownloadFileAsync($url,$localFile)

		while (!($Global:downloadComplete)) {
			$pc = $Global:DPCEventArgs.ProgressPercentage
			if ($pc -ne $null) {
				Write-Progress -Activity 'Downloading file' -Status $url -PercentComplete $pc
			}
		}

		Write-Progress -Activity 'Downloading file' -Status $url -Complete
	}
	end {
		Unregister-Event -SourceIdentifier WebClient.DownloadProgressChanged
		Unregister-Event -SourceIdentifier WebClient.DownloadFileComplete
		$client.Dispose()
		$Global:downloadComplete = $null
		$Global:DPCEventArgs = $null
		Remove-Variable client
		Remove-Variable eventDataComplete
		Remove-Variable eventDataProgress
		[GC]::Collect()
	}
}
