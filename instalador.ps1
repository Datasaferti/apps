function Show-Menu {
    Clear-Host
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "                          MENU DE INSTALAÇÃO DATASAFER TI                    " -ForegroundColor Cyan
    Write-Host "=============================================================================" -ForegroundColor Cyan
    
    # Organizando em 4 colunas (10 itens por coluna)
    $col1 = @("1. Google Chrome", "2. Mozilla Firefox", "3. Brave Browser", "4. Microsoft Edge", "5. Opera GX", "6. Vivaldi", "7. Discord", "8. Telegram", "9. WhatsApp", "10. Zoom")
    $col2 = @("11. Slack", "12. MS Teams", "13. TeamSpeak", "14. VLC Player", "15. OBS Studio", "16. Spotify", "17. HandBrake", "18. Foobar2000", "19. Audacity", "20. 7-Zip")
    $col3 = @("21. WinRAR", "22. Notepad++", "23. VS Code", "24. LibreOffice", "25. Acrobat Reader", "26. Rufus", "27. AnyDesk", "28. TeamViewer", "29. PowerToys", "30. Steam")
    $col4 = @("31. Epic Games", "32. GOG Galaxy", "33. EA App", "34. Battle.net", "35. Git", "36. Python", "37. Docker Desktop", "38. Putty", "39. Cloudflare WARP", "40. Mullvad VPN")

    for ($i = 0; $i -lt 10; $i++) {
        $line = "{0,-22} {1,-22} {2,-22} {3,-22}" -f $col1[$i], $col2[$i], $col3[$i], $col4[$i]
        Write-Host $line
    }
    
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "  99. INSTALAR TUDO (Pacote Completo)                         0. Sair"
    Write-Host "=============================================================================" -ForegroundColor Cyan
}

function Install-App {
    param([string]$packageName)
    Write-Host "`nInstalando $packageName..." -ForegroundColor Yellow
    choco install $packageName -y
    Write-Host "Concluido!`n" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

 $exit = $false
while (-not $exit) {
    Show-Menu
    $choice = Read-Host "Digite o numero do programa que deseja instalar"
    
    $app = ""
    switch ($choice) {
        "1" { $app = "googlechrome" }
        "2" { $app = "firefox" }
        "3" { $app = "brave" }
        "4" { $app = "microsoft-edge" }
        "5" { $app = "opera-gx" }
        "6" { $app = "vivaldi" }
        "7" { $app = "discord" }
        "8" { $app = "telegram" }
        "9" { $app = "whatsapp" }
        "10" { $app = "zoom" }
        "11" { $app = "slack" }
        "12" { $app = "microsoft-teams" }
        "13" { $app = "teamspeak" }
        "14" { $app = "vlc" }
        "15" { $app = "obs-studio" }
        "16" { $app = "spotify" }
        "17" { $app = "handbrake" }
        "18" { $app = "foobar2000" }
        "19" { $app = "audacity" }
        "20" { $app = "7zip" }
        "21" { $app = "winrar" }
        "22" { $app = "notepadplusplus" }
        "23" { $app = "vscode" }
        "24" { $app = "libreoffice-fresh" }
        "25" { $app = "adobereader" }
        "26" { $app = "rufus" }
        "27" { $app = "anydesk" }
        "28" { $app = "teamviewer" }
        "29" { $app = "powertoys" }
        "30" { $app = "steam" }
        "31" { $app = "epicgameslauncher" }
        "32" { $app = "goggalaxy" }
        "33" { $app = "ea-app" }
        "34" { $app = "battle.net" }
        "35" { $app = "git" }
        "36" { $app = "python" }
        "37" { $app = "docker-desktop" }
        "38" { $app = "putty" }
        "39" { $app = "cloudflare-warp" }
        "40" { $app = "mullvad" }
        "99" {
            Write-Host "Instalando TODOS os pacotes... Isso pode demorar!" -ForegroundColor Red
            $allApps = @("googlechrome", "firefox", "brave", "microsoft-edge", "opera-gx", "vivaldi", "discord", "telegram", "whatsapp", "zoom", "slack", "microsoft-teams", "teamspeak", "vlc", "obs-studio", "spotify", "handbrake", "foobar2000", "audacity", "7zip", "winrar", "notepadplusplus", "vscode", "libreoffice-fresh", "adobereader", "rufus", "anydesk", "teamviewer", "powertoys", "steam", "epicgameslauncher", "goggalaxy", "ea-app", "battle.net", "git", "python", "docker-desktop", "putty", "cloudflare-warp", "mullvad")
            foreach ($pkg in $allApps) { Install-App $pkg }
            $app = "skip"
        }
        "0" { 
            Write-Host "Saindo..." -ForegroundColor Cyan
            $exit = $true
            $app = "skip"
        }
        default { 
            Write-Host "Opcao invalida! Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 2
            $app = "skip"
        }
    }
    
    if (-not $exit -and $app -ne "skip") {
        Install-App $app
    }
}
