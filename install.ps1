# =============================================================================
#          GERENCIADOR DE IMPLANTAÇÃO - DATASAFER TI
# =============================================================================

# Garante privilégios de Administrador logo na entrada
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Define o diretório atual onde este script está rodando
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Show-WelcomeMenu {
    Clear-Host
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "                     GERENCIADOR DE INSTALACAO - DATASAFER TI                " -ForegroundColor Cyan
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Escolha o gerenciador de pacotes que deseja utilizar para a instalacao:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Chocolatey (Usa o script 'instalador.ps1')" -ForegroundColor Yellow
    Write-Host "  [2] WinGet     (Usa o script 'winget.ps1')" -ForegroundColor Green
    Write-Host ""
    Write-Host "  [0] Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Cyan
}

$exitManager = $false
while (-not $exitManager) {
    Show-WelcomeMenu
    $choice = Read-Host "Digite a opcao desejada (1, 2 ou 0)"

    switch ($choice) {
        "1" {
            $scriptChoco = Join-Path $currentDir "instalador.ps1"
            if (Test-Path $scriptChoco) {
                Write-Host "`n[+] Abrindo instalador via Chocolatey..." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                # Executa o script do chocolatey na mesma sessão
                & $scriptChoco
                $exitManager = $true
            } else {
                Write-Host "`n[Erro] Arquivo 'instalador.ps1' nao foi encontrado na pasta: $currentDir" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
        
        "2" {
            $scriptWinget = Join-Path $currentDir "winget.ps1"
            if (Test-Path $scriptWinget) {
                Write-Host "`n[+] Abrindo instalador via WinGet..." -ForegroundColor Green
                Start-Sleep -Seconds 1
                # Executa o script do winget na mesma sessão
                & $scriptWinget
                $exitManager = $true
            } else {
                Write-Host "`n[Erro] Arquivo 'winget.ps1' nao foi encontrado na pasta: $currentDir" -ForegroundColor Red
                Start-Sleep -Seconds 3
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
