# =============================================================================
#           SCRIPT DE INSTALAÇÃO DATASAFER TI (VERSÃO CHOCOLATEY)
# =============================================================================

# Garante privilégios de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador!"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

function Show-Menu {
    Clear-Host
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "                        MENU DE INSTALACAO DATASAFER TI                      " -ForegroundColor Cyan
    Write-Host "=============================================================================" -ForegroundColor Cyan
    
    $col1 = @("1. Google Chrome", "2. Mozilla Firefox", "3. Brave Browser", "4. Microsoft Edge", "5. Opera GX", "6. Vivaldi", "7. Discord", "8. Telegram", "9. WhatsApp", "10. Zoom")
    $col2 = @("11. Slack", "12. MS Teams", "13. TeamSpeak", "14. VLC Player", "15. OBS Studio", "16. Spotify", "17. HandBrake", "18. Foobar2000", "19. Audacity", "20. 7-Zip")
    $col3 = @("21. WinRAR", "22. Notepad++", "23. VS Code", "24. LibreOffice", "25. Acrobat Reader", "26. Rufus", "27. AnyDesk", "28. TeamViewer", "29. Git", "30. Python")
    $col4 = @("31. Docker Desktop", "32. Putty", "33. Cloudflare WARP", "34. Mullvad VPN", "35. Radmin VPN", "36. CrystalDiskInfo", "37. RAMMap (Sysinternals)")

    for ($i = 0; $i -lt 10; $i++) {
        $line = "{0,-22} {1,-22} {2,-22} {3,-22}" -f $col1[$i], $col2[$i], $col3[$i], $col4[$i]
        Write-Host $line
    }
    
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host " 99. INSTALAR TUDO (Pacote Completo)                         0. Sair"
    Write-Host " DICA: Para instalar varios, separe por virgula (ex: 1, 2, 3)"
    Write-Host "=============================================================================" -ForegroundColor Cyan
}

function Install-App {
    # Agora aceita um array de nomes de pacotes
    param([string[]]$packageNames)
    
    if ($packageNames.Count -eq 0) { return }
    
    Write-Host "`nInstalando: $($packageNames -join ', ')..." -ForegroundColor Yellow
    
    $chocoPath = "C:\ProgramData\chocolatey\bin\choco.exe"
    
    # Se o Chocolatey nao existir, baixa e instala de forma isolada
    if (-not (Test-Path $chocoPath)) {
        Write-Host "Chocolatey nao encontrado. Instalando o Chocolatey primeiro..." -ForegroundColor Red
        $chocoInstallScript = "$env:TEMP\install_choco.ps1"
        Invoke-WebRequest -Uri "https://community.chocolatey.org/install.ps1" -OutFile $chocoInstallScript -UseBasicParsing
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$chocoInstallScript`"" -Wait -NoNewWindow
        Remove-Item $chocoInstallScript -Force -ErrorAction SilentlyContinue
    }
    
    # Instala todos os pacotes passados de uma vez
    if (Test-Path $chocoPath) {
        Write-Host "Iniciando instalacao via Chocolatey..." -ForegroundColor Cyan
        & $chocoPath install $packageNames -y
    } else {
        Write-Host "Erro: Chocolatey nao foi instalado corretamente." -ForegroundColor Red
    }
    
    Write-Host "Concluido!`n" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Dicionario atualizado - removidos jogos/launchers, adicionadas ferramentas de diagnostico e rede
 $appDictionary = @{
    "1"  = "googlechrome"; "2"  = "firefox"; "3"  = "brave"; "4"  = "microsoft-edge"; "5"  = "opera-gx"
    "6"  = "vivaldi"; "7"  = "discord"; "8"  = "telegram"; "9"  = "whatsapp"; "10" = "zoom"
    "11" = "slack"; "12" = "microsoft-teams"; "13" = "teamspeak"; "14" = "vlc"; "15" = "obs-studio"
    "16" = "spotify"; "17" = "handbrake"; "18" = "foobar2000"; "19" = "audacity"; "20" = "7zip"
    "21" = "winrar"; "22" = "notepadplusplus"; "23" = "vscode"; "24" = "libreoffice-fresh"; "25" = "adobereader"
    "26" = "rufus"; "27" = "anydesk"; "28" = "teamviewer"; "29" = "git"; "30" = "python"
    "31" = "docker-desktop"; "32" = "putty"; "33" = "cloudflare-warp"; "34" = "mullvad"
    "35" = "radmin-vpn"; "36" = "crystaldiskinfo"; "37" = "rammap"
}

 $exit = $false
while (-not $exit) {
    Show-Menu
    $choice = Read-Host "Digite os numeros (ex: 1,2,3) ou 0 para sair"
    
    if ($choice -eq "0") {
        Write-Host "Saindo..." -ForegroundColor Cyan
        $exit = $true
        continue
    }
    
    if ($choice -eq "99") {
        Write-Host "Instalando TODOS os pacotes... Isso pode demorar!" -ForegroundColor Red
        Install-App $appDictionary.Values
        continue
    }
    
    # Separa os numeros digitados por virgula
    $selectedNumbers = $choice -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    
    $appsToInstall = @()
    $invalidOptions = @()
    
    foreach ($num in $selectedNumbers) {
        if ($appDictionary.ContainsKey($num)) {
            $appsToInstall += $appDictionary[$num]
        } else {
            $invalidOptions += $num
        }
    }
    
    if ($invalidOptions.Count -gt 0) {
        Write-Host "Opcoes invalidas ignoradas: $($invalidOptions -join ', ')" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
    
    if ($appsToInstall.Count -gt 0) {
        Install-App $appsToInstall
    } else {
        Write-Host "Nenhuma opcao valida selecionada." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}
