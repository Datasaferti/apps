# =============================================================================
#          GERENCIADOR DE IMPLANTAÇÃO REMOTO - DATASAFER TI
# =============================================================================

# Garante privilégios de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# URLs do conteúdo bruto (Raw) direto do seu GitHub
$urlChoco  = "https://raw.githubusercontent.com/Datasaferti/apps/refs/heads/main/instalador.ps1"
$urlWinget = "https://raw.githubusercontent.com/Datasaferti/apps/refs/heads/main/winget.ps1"

function Show-WelcomeMenu {
    Clear-Host
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "                     GERENCIADOR DE INSTALACAO - DATASAFER TI                " -ForegroundColor Cyan
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Escolha o gerenciador de pacotes que deseja utilizar para a instalacao:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. Chocolatey (Usa o script remoto 'instalador.ps1')" -ForegroundColor Yellow
    Write-Host "  2. WinGet     (Usa o script remoto 'winget.ps1')" -ForegroundColor Green
    Write-Host ""
    Write-Host "  0. Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Cyan
}

$exitManager = $false
while (-not $exitManager) {
    Show-WelcomeMenu
    $choice = Read-Host "Digite a opcao desejada (1, 2 ou 0)"

    switch ($choice) {
        "1" {
            Write-Host "`n[+] Baixando e abrindo instalador via Chocolatey..." -ForegroundColor Yellow
            try {
                # Baixa e executa o código direto na memória da sessão atual
                $scriptContent = Invoke-RestMethod -Uri $urlChoco -UseBasicParsing
                Invoke-Expression $scriptContent
                $exitManager = $true
            }
            catch {
                Write-Host "`n[Erro] Falha ao conectar ou baixar o script do Chocolatey do GitHub." -ForegroundColor Red
                Write-Host "Detalhe: $_" -ForegroundColor DarkRed
                Start-Sleep -Seconds 4
            }
        }
        
        "2" {
            Write-Host "`n[+] Baixando e abrindo instalador via WinGet..." -ForegroundColor Green
            try {
                # Baixa e executa o código direto na memória da sessão atual
                $scriptContent = Invoke-RestMethod -Uri $urlWinget -UseBasicParsing
                Invoke-Expression $scriptContent
                $exitManager = $true
            }
            catch {
                Write-Host "`n[Erro] Falha ao conectar ou baixar o script do WinGet do GitHub." -ForegroundColor Red
                Write-Host "Detalhe: $_" -ForegroundColor DarkRed
                Start-Sleep -Seconds 4
            }
        }

        "0" {
            Write-Host "`nSaindo do gerenciador..." -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            $exitManager = $true
        }

        Default {
            Write-Host "`nOpcao invalida! Escolha 1, 2 ou 0." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
