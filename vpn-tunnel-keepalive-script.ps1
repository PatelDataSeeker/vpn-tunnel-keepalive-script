# Read configuration file
$configPath = Join-Path $PSScriptRoot "config.json"
try {
    $configContent = Get-Content -Path $configPath -Raw
    $config = $configContent | ConvertFrom-Json
} catch {
    Write-Error "Error reading config file: $_"
    exit 1
}

# Create log directory if it doesn't exist
try {
    $logDir = Split-Path -Path $config.logFilePath -Parent
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force
    }
} catch {
    Write-Error "Error creating log directory: $_"
    exit 1
}

# Monitor each interface
foreach ($interface in $config.interfaces) {
    if ([string]::IsNullOrWhiteSpace($interface.ip)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp - Interface Name: $($interface.name), Interface Port: $($interface.port), Remote IP Address: No IP Configured, Status: Skipped, Response Time: 0 ms"
        Add-Content -Path $config.logFilePath -Value $logEntry
        continue
    }

    $pingOutput = ping -n 1 $interface.ip
    $status = "Failed"
    $responseTime = 0

    foreach ($line in $pingOutput) {
        if ($line -match "Average = (\d+)ms") {
            $status = "Success"
            $responseTime = $matches[1]
            break
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - Interface Name: $($interface.name), Interface Port: $($interface.port), Remote IP Address: $($interface.ip), Status: $status, Response Time: $responseTime ms"
    Add-Content -Path $config.logFilePath -Value $logEntry
    
    if ($interface -ne $config.interfaces[-1]) {
        Start-Sleep -Seconds 3
    }
}
