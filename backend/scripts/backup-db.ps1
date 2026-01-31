# Database Backup Script for Windows (PowerShell)
# TrendX Database Backup

param(
    [string]$BackupDir = ".\backups",
    [string]$DbName = "trendx",
    [string]$MongoUri = "mongodb://localhost:27017",
    [int]$RetentionDays = 7
)

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupPath = Join-Path $BackupDir "${DbName}_$Timestamp"

Write-Host "========================================" -ForegroundColor Green
Write-Host "TrendX Database Backup Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Create backup directory
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
}

# Perform backup
Write-Host "Starting backup..." -ForegroundColor Yellow
Write-Host "Database: $DbName"
Write-Host "Target: $BackupPath"
Write-Host ""

$mongodumpCmd = "mongodump --uri=`"$MongoUri`" --db=`"$DbName`" --out=`"$BackupPath`" --gzip"

try {
    Invoke-Expression $mongodumpCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Backup completed successfully" -ForegroundColor Green
        
        # Compress backup
        Write-Host "Compressing backup..." -ForegroundColor Yellow
        $CompressedPath = Join-Path $BackupDir "${DbName}_${Timestamp}.zip"
        Compress-Archive -Path $BackupPath -DestinationPath $CompressedPath
        Remove-Item -Path $BackupPath -Recurse -Force
        
        $CompressedSize = (Get-Item $CompressedPath).Length / 1MB
        Write-Host "✓ Compressed to: $([math]::Round($CompressedSize, 2)) MB" -ForegroundColor Green
        
        # Clean old backups
        Write-Host "Cleaning old backups (older than $RetentionDays days)..." -ForegroundColor Yellow
        $CutoffDate = (Get-Date).AddDays(-$RetentionDays)
        Get-ChildItem -Path $BackupDir -Filter "${DbName}_*.zip" | 
            Where-Object { $_.LastWriteTime -lt $CutoffDate } | 
            Remove-Item -Force
        
        $RemainingBackups = (Get-ChildItem -Path $BackupDir -Filter "${DbName}_*.zip").Count
        Write-Host "✓ Remaining backups: $RemainingBackups" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Backup completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        exit 0
    } else {
        throw "mongodump failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "✗ Backup failed: $_" -ForegroundColor Red
    exit 1
}
