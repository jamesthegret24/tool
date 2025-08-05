# Simple HTTP Server using PowerShell

$Hso = New-Object Net.HttpListener
$Hso.Prefixes.Add("http://localhost:8000/")
$Hso.Start()

Write-Host "HTTP Server started at http://localhost:8000/"
Write-Host "Press Ctrl+C to stop the server"

try {
    while ($Hso.IsListening) {
        $HC = $Hso.GetContext()
        $HRes = $HC.Response
        $HReq = $HC.Request
        
        $FilePath = Join-Path (Get-Location).Path $HReq.Url.LocalPath.Substring(1)
        
        if (Test-Path $FilePath -PathType Leaf) {
            $ContentType = "text/plain"
            
            # Set content type based on file extension
            switch ([System.IO.Path]::GetExtension($FilePath)) {
                ".html" { $ContentType = "text/html" }
                ".css"  { $ContentType = "text/css" }
                ".js"   { $ContentType = "application/javascript" }
                ".json" { $ContentType = "application/json" }
                ".png"  { $ContentType = "image/png" }
                ".jpg"  { $ContentType = "image/jpeg" }
                ".gif"  { $ContentType = "image/gif" }
            }
            
            $HRes.ContentType = $ContentType
            $FileContent = [System.IO.File]::ReadAllBytes($FilePath)
            $HRes.ContentLength64 = $FileContent.Length
            $HRes.OutputStream.Write($FileContent, 0, $FileContent.Length)
            
            Write-Host "[200] $($HReq.HttpMethod) $($HReq.Url.LocalPath)"
        } else {
            $HRes.StatusCode = 404
            $NotFoundMessage = "404 - File Not Found: $($HReq.Url.LocalPath)"
            $HRes.ContentType = "text/plain"
            $HRes.ContentLength64 = $NotFoundMessage.Length
            $HRes.OutputStream.Write([System.Text.Encoding]::ASCII.GetBytes($NotFoundMessage), 0, $NotFoundMessage.Length)
            
            Write-Host "[404] $($HReq.HttpMethod) $($HReq.Url.LocalPath)"
        }
        
        $HRes.Close()
    }
} finally {
    $Hso.Stop()
    Write-Host "HTTP Server stopped"
}