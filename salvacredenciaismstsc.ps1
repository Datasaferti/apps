# Verifica se o PowerShell esta rodando como Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "Por favor, feche o ISE e abra-o novamente clicando com o botao direito e escolhendo 'Executar como Administrador'."
    Break
}

Write-Host "Iniciando a configuracao de credenciais do RDP..." -ForegroundColor Cyan

# 1. Configura DisableDomainCreds para 0
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
New-ItemProperty -Path $lsaPath -Name "DisableDomainCreds" -Value 0 -PropertyType DWord -Force | Out-Null
Write-Host "[OK] Chave DisableDomainCreds configurada para 0." -ForegroundColor Green

# 2. Cria a pasta CredentialsDelegation caso nao exista e configura AllowSavedCredentialsWhenNTLMOnly para 1
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation"

if (-not (Test-Path $policyPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "CredentialsDelegation" -Force | Out-Null
    Write-Host "[OK] Pasta CredentialsDelegation criada com sucesso." -ForegroundColor Green
}

New-ItemProperty -Path $policyPath -Name "AllowSavedCredentialsWhenNTLMOnly" -Value 1 -PropertyType DWord -Force | Out-Null
Write-Host "[OK] Chave AllowSavedCredentialsWhenNTLMOnly configurada para 1." -ForegroundColor Green

Write-Host "`n[SUCESSO] Todas as alteracoes foram aplicadas!" -ForegroundColor Yellow
Write-Host "Por favor, reinicie o computador para que o Windows aplique as novas regras." -ForegroundColor Yellow
##########################################################################################################################
# Define o caminho da chave do Registro para as políticas do cliente RDP
$registryPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\Client"

# Cria a chave de pasta caso ela ainda não exista no sistema
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Adiciona o valor DWORD que desativa a nova janela de aviso de segurança
New-ItemProperty -Path $registryPath -Name "RedirectionWarningDialogVersion" -Value 1 -PropertyType DWORD -Force
