# =============================================================================
#           SCRIPT DE INSTALAÇÃO DATASAFER TI (VERSÃO WINGET NATIVA)
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
    $col3 = @("21. WinRAR", "22. Notepad++", "23. VS Code", "24. LibreOffice", "25. Acrobat Reader", "26. Rufus", "27. AnyDesk", "28. TeamViewer", "29. PowerToys", "30. Steam")
    $col4 = @("31. Epic Games", "32. GOG Galaxy", "33. EA App", "34. Battle.net", "35. Git", "36. Python", "37. Docker Desktop", "38. Putty", "39. Cloudflare WARP", "40. Mullvad VPN")

    for ($i = 0; $i -lt 10; $i++) {
        $line = "{0,-22} {1,-22} {2,-22} {3,-22}" -f $col1[$i], $col2[$i], $col3[$i], $col4[$i]
        Write-Host $line
    }
    
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host " 99. INSTALAR TUDO (Pacote Completo)                         0. Sair"
    Write-Host " DICA: Para instalar varios, separe por virgula (ex: 1, 2, 3)"
    Write-Host "=============================================================================" -ForegroundColor Cyan
}

# Função para garantir a presença e o funcionamento do WinGet
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return
    }

    Write-Host "WinGet nao encontrado. Iniciando instalacao automatizada do WinGet..." -ForegroundColor Red
    
    $tempDir = Join-Path $env:TEMP "WingetInstaller"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    try {
        Write-Host "-> Baixando dependencias estruturais..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://aka.ms" -OutFile "$tempDir\VCLibs.appx" -UseBasicParsing
        Invoke-WebRequest -Uri "https://github.com" -OutFile "$tempDir\UiXaml.appx" -UseBasicParsing
        
        Write-Host "-> Baixando instalador oficial do WinGet..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://aka.ms" -OutFile "$tempDir\Winget.msixbundle" -UseBasicParsing

        Write-Host "-> Registrando pacotes no sistema..." -ForegroundColor Cyan
        Add-AppxPackage -Path "$tempDir\VCLibs.appx" -ErrorAction SilentlyContinue
        Add-AppxPackage -Path "$tempDir\UiXaml.appx" -ErrorAction SilentlyContinue
        Add-AppxPackage -Path "$tempDir\Winget.msixbundle"

        Write-Host "[✓] WinGet instalado com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Error "Falha critica ao tentar instalar o WinGet: $_"
        Exit 1
    }
    finally {
        Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
    }

    # Atualiza as variaveis de ambiente da sessao corrente
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Install-App {
    param([string[]]$packageIds)
    
    if ($packageIds.Count -eq 0) { return }
    
    # Executa a checagem inteligente do WinGet antes de instalar
    Ensure-Winget
    
    Write-Host "`nPreparando para instalar: $($packageIds -join ', ')..." -ForegroundColor Yellow
    Write-Host "Iniciando instalacao via WinGet..." -ForegroundColor Cyan
    
    # No WinGet instalamos iterando um a um para aplicar as flags de aceite silencioso individuais
    foreach ($id in $packageIds) {
        Write-Host "`nInstalando: $id..." -ForegroundColor Cyan
        
        # Flags aceitam os termos de fontes/contratos de forma silenciosa automaticamente
        winget install --id $id --silent --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[✓] $id Concluido com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "[!] Finalizado ou requer revisao para: $id (Codigo de Saida: $LASTEXITCODE)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nLote de instalacao finalizado!`n" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Dicionario atualizado com os IDs Oficiais do repositório WinGet (Equivalentes ao Chocolatey antigo)
$appDictionary = @{
    "1"  = "Google.Chrome"; "2"  = "Mozilla.Firefox"; "3"  = "Brave.Brave"; "4"  = "Microsoft.Edge"; "5"  = "Opera.OperaGX"
    "6"  = "VivaldiTechnologies.Vivaldi"; "7"  = "Discord.Discord"; "8"  = "Telegram.TelegramDesktop"; "9"  = "WhatsApp.WhatsApp"; "10" = "Zoom.Zoom"
    "11" = "SlackTechnologies.Slack"; "12" = "Microsoft.Teams"; "13" = "TeamSpeakSystems.TeamSpeak"; "14" = "VideoLAN.VLC"; "15" = "OBSProject.OBSStudio"
    "16" = "Spotify.Spotify"; "17" = "HandBrake.HandBrake"; "18" = "foobar2000.foobar2000"; "19" = "Audacity.Audacity"; "20" = "7zip.7zip"
    "21" = "RARLab.WinRAR"; "22" = "Notepad++.Notepad++"; "23" = "Microsoft.VisualStudioCode"; "24" = "DocumentFoundation.LibreOffice"; "25" = "Adobe.Acrobat.Reader.64-bit"
    "26" = "Akeo.Rufus"; "27" = "AnyDesk.AnyDesk"; "28" = "TeamViewer.TeamViewer"; "29" = "Microsoft.PowerToys"; "30" = "Valve.Steam"
    "31" = "EpicGames.EpicGamesLauncher"; "32" = "GOG.Galaxy"; "33" = "ElectronicArts.EADesktop"; "34" = "Blizzard.BattleNet"; "35" = "Git.Git"
    "36" = "Python.Python.3.12"; "37" = "Docker.DockerDesktop"; "38" = "SimonTatham.PuTTY"; "39" = "Cloudflare.Warp"; "40" = "MullvadVPN.MullvadVPN"
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
        Write-Host "Instalando TODOS os pacotes... Isso pode demorar significativamente!" -ForegroundColor Red
        Install-App $appDictionary.Values
        continue
    }
    
    # Separa as opções digitadas por vírgula
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
