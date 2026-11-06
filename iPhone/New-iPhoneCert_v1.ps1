<#
  New-iPhoneCert_v1.ps1
  Creates a local root CA (only once) and an HTTPS server certificate for this PC,
  so web apps served from this PC over Wi-Fi run on the iPhone with full features.

  Output in -OutDir:
    iPhoneDevCA.cer   install on the iPhone once, then enable full trust
    server.pfx        certificate + key for the local HTTPS server

  Run again whenever the PC gets a new IP address: the CA is reused,
  so the iPhone does not need to install anything again.

  Run:  powershell -ExecutionPolicy Bypass -File New-iPhoneCert_v1.ps1
#>
param(
  [string]$OutDir = (Join-Path $PSScriptRoot 'cert'),
  [string]$CAName = 'iPhone Dev Local CA',
  [string]$PfxPassword = 'iphone',
  [string[]]$ExtraIP = @()
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# 1. Root CA - reuse the existing one so the iPhone trusts it only once.
$ca = Get-ChildItem Cert:\CurrentUser\My |
  Where-Object { $_.Subject -eq "CN=$CAName" -and $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date).AddDays(30) } |
  Sort-Object NotAfter -Descending | Select-Object -First 1
if ($ca) {
  Write-Host "Using existing CA   $($ca.Thumbprint)  (valid until $($ca.NotAfter.ToString('yyyy-MM-dd')))"
} else {
  $ca = New-SelfSignedCertificate -Subject "CN=$CAName" -FriendlyName $CAName `
    -CertStoreLocation Cert:\CurrentUser\My -KeyExportPolicy Exportable `
    -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
    -KeyUsage CertSign, CRLSign, DigitalSignature `
    -TextExtension @('2.5.29.19={critical}{text}ca=true&pathlength=0') `
    -NotAfter (Get-Date).AddYears(10)
  Write-Host "Created new CA      $($ca.Thumbprint)"
}

# 2. Server certificate for this PC's names and IPv4 addresses.
$ips = @(Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
  Select-Object -ExpandProperty IPAddress) + $ExtraIP + '127.0.0.1' | Select-Object -Unique
$names = @($env:COMPUTERNAME, "$env:COMPUTERNAME.local", 'localhost')
$san = (@($names | ForEach-Object { "DNS=$_" }) + @($ips | ForEach-Object { "IPAddress=$_" })) -join '&'

# iOS accepts at most 825 days; 397 also satisfies the stricter 398-day rule.
$server = New-SelfSignedCertificate -Subject "CN=$env:COMPUTERNAME" -FriendlyName "iPhone Dev Server ($env:COMPUTERNAME)" `
  -Signer $ca -CertStoreLocation Cert:\CurrentUser\My -KeyExportPolicy Exportable `
  -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
  -KeyUsage DigitalSignature, KeyEncipherment `
  -TextExtension @("2.5.29.17={text}$san", '2.5.29.37={text}1.3.6.1.5.5.7.3.1', '2.5.29.19={text}ca=false') `
  -NotAfter (Get-Date).AddDays(397)

# 3. Save files.
$caFile = Join-Path $OutDir 'iPhoneDevCA.cer'
$pfxFile = Join-Path $OutDir 'server.pfx'
Export-Certificate -Cert $ca -FilePath $caFile -Type CERT | Out-Null
Export-PfxCertificate -Cert $server -FilePath $pfxFile -ChainOption EndEntityCertOnly `
  -Password (ConvertTo-SecureString $PfxPassword -AsPlainText -Force) | Out-Null

# The server certificate lives in server.pfx; keep only the CA in the store.
Remove-Item -Path "Cert:\CurrentUser\My\$($server.Thumbprint)"

Write-Host ''
Write-Host "CA for iPhone       $caFile"
Write-Host "Server certificate  $pfxFile   (password: $PfxPassword)"
Write-Host "Valid until         $($server.NotAfter.ToString('yyyy-MM-dd'))"
Write-Host "Names               $($names -join ', ')"
Write-Host "IP addresses        $($ips -join ', ')"
Write-Host ''
Write-Host 'iPhone, once:'
Write-Host '  1. Get iPhoneDevCA.cer onto the iPhone (mail it to yourself, or iCloud Drive) and tap it.'
Write-Host "  2. Settings > General > VPN & Device Management > $CAName > Install."
Write-Host "  3. Settings > General > About > Certificate Trust Settings > turn on $CAName."
