# Executar este script obrigatoriamente como Administrador

# 1. Desativa as novas políticas do Credential Guard que bloqueiam senhas salvas de RDP
$deviceGuardPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
if (-not (Test-Path $deviceGuardPath)) { New-Item -Path $deviceGuardPath -Force | Out-Null }
Set-ItemProperty -Path $deviceGuardPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $deviceGuardPath -Name "RequirePlatformSecurityFeatures" -Value 0 -Type DWord -Force

# 2. Desativa a proteção LSA contra delegação de senhas locais sem Kerberos
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $lsaPath -Name "LsaCfgFlags" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $lsaPath -Name "DisableDomainCreds" -Value 0 -Type DWord -Force

# 3. Força as diretivas de cliente do MSTSC a nunca exigirem prompts ou bloquearem senhas
$clientPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client"
if (-not (Test-Path $clientPath)) { New-Item -Path $clientPath -Force | Out-Null }
Set-ItemProperty -Path $clientPath -Name "DisablePasswordSaving" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $clientPath -Name "PromptForCredentials" -Value 0 -Type DWord -Force

# 4. Remove qualquer cache corrompido ou travado anterior
cmdkey /list | Select-String "target=TERMSRV/catalogo" | ForEach-Object {
    cmdkey /delete:TERMSRV/catalogo
}

# 5. Injeta a credencial definitiva de forma limpa no novo formato aceito pós-atualização
cmdkey /generic:"TERMSRV/catalogo" /user:"pc8" /pass:"123456"

# 6. Atualiza e recarrega o subsistema de segurança do Windows
gpupdate /force

Write-Host "Modificações de segurança aplicadas!" -ForegroundColor Green
Write-Host "IMPORTANTE: Reinicie o computador agora para descarregar o isolamento de credenciais da memória." -ForegroundColor Yellow
