# =============================================================================
#           SCRIPT DE INSTALAÇÃO DATASAFER TI (VERSÃO WINGET NATIVA)
#        IDs validados via winget search (30 confirmados + 7 corrigidos)
# =============================================================================

# Forca TLS 1.2 (necessario para downloads em PowerShell mais antigos)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

function New-CrystalDiskInfoShortcut {
    # Localiza o executavel do CrystalDiskInfo (instalacao tradicional ou portable
    # do WinGet) e garante que exista atalho no Menu Iniciar.
    try {
        $candidates = @(
            "C:\Program Files\CrystalDiskInfo\DiskInfo64.exe"
            "C:\Program Files (x86)\CrystalDiskInfo\DiskInfo64.exe"
        )
        $exePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

        if (-not $exePath) {
            $pkgDir = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Directory -Filter "CrystalDewWorld.CrystalDiskInfo*" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($pkgDir) {
                $found = Get-ChildItem $pkgDir.FullName -Recurse -Include "DiskInfo64.exe","DiskInfo32.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) { $exePath = $found.FullName }
            }
        }

        if (-not $exePath) { return $false }

        $lnkPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\CrystalDiskInfo.lnk"
        if (Test-Path $lnkPath) { return $true }

        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($lnkPath)
        $lnk.TargetPath = $exePath
        $lnk.WorkingDirectory = Split-Path $exePath
        $lnk.Save()
        return $true
    } catch {
        return $false
    }
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
        Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "$tempDir\VCLibs.appx" -UseBasicParsing
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" -OutFile "$tempDir\UiXaml.appx" -UseBasicParsing
        
        Write-Host "-> Baixando instalador oficial do WinGet..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$tempDir\Winget.msixbundle" -UseBasicParsing

        Write-Host "-> Registrando pacotes no sistema..." -ForegroundColor Cyan
        Add-AppxPackage -Path "$tempDir\VCLibs.appx" -ErrorAction SilentlyContinue
        Add-AppxPackage -Path "$tempDir\UiXaml.appx"
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
    
    foreach ($entry in $packageIds) {
        # Suporte a fonte alternativa: "msstore:<ID>" instala pela Microsoft Store
        $source = "winget"
        $id = $entry
        if ($entry -like "msstore:*") {
            $source = "msstore"
            $id = $entry -replace "^msstore:", ""
        }
        
        Write-Host "`nInstalando: $id..." -ForegroundColor Cyan
        
        if ($source -eq "msstore") {
            # Apps da Store: instala pelo ProductId (sem --exact, IDs da loja sao unicos)
            winget install --id $id --source msstore --silent --accept-source-agreements --accept-package-agreements
        } else {
            # --exact evita conflitos com pacotes de nome parecido (ex: edicoes Shizuku/Aoi do CrystalDiskInfo)
            winget install --id $id --exact --silent --accept-source-agreements --accept-package-agreements
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[✓] $id Concluido com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "[!] Finalizado ou requer revisao para: $id (Codigo de Saida: $LASTEXITCODE)" -ForegroundColor Yellow
        }
        
        # Caso especial: garante o atalho do CrystalDiskInfo no Menu Iniciar
        if ($id -eq "CrystalDewWorld.CrystalDiskInfo") {
            if (New-CrystalDiskInfoShortcut) {
                Write-Host "[✓] Atalho do CrystalDiskInfo disponivel no Menu Iniciar!" -ForegroundColor Green
            } else {
                Write-Host "[i] Nao foi possivel confirmar o atalho. Abra o app pesquisando 'CrystalDiskInfo' no menu." -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "`nLote de instalacao finalizado!`n" -ForegroundColor Green
    Start-Sleep -Seconds 3
}

# Dicionario ORDENADO - todos os IDs validados via winget search
# (item 9 = WhatsApp oficial, distribuido somente pela Microsoft Store)
 $appDictionary = [ordered]@{
    "1"  = "Google.Chrome"; "2"  = "Mozilla.Firefox"; "3"  = "Brave.Brave"; "4"  = "Microsoft.Edge"; "5"  = "Opera.OperaGX"
    "6"  = "Vivaldi.Vivaldi"; "7"  = "Discord.Discord"; "8"  = "Telegram.TelegramDesktop"; "9"  = "msstore:9NKSQGP7F2NH"; "10" = "Zoom.Zoom"
    "11" = "SlackTechnologies.Slack"; "12" = "Microsoft.Teams"; "13" = "TeamSpeakSystems.TeamSpeakClient"; "14" = "VideoLAN.VLC"; "15" = "OBSProject.OBSStudio"
    "16" = "Spotify.Spotify"; "17" = "HandBrake.HandBrake"; "18" = "PeterPawlowski.foobar2000"; "19" = "Audacity.Audacity"; "20" = "7zip.7zip"
    "21" = "RARLab.WinRAR"; "22" = "Notepad++.Notepad++"; "23" = "Microsoft.VisualStudioCode"; "24" = "TheDocumentFoundation.LibreOffice"; "25" = "Adobe.Acrobat.Reader.64-bit"
    "26" = "Rufus.Rufus"; "27" = "AnyDesk.AnyDesk"; "28" = "TeamViewer.TeamViewer"; "29" = "Git.Git"; "30" = "Python.Python.3.12"
    "31" = "Docker.DockerDesktop"; "32" = "PuTTY.PuTTY"; "33" = "Cloudflare.Warp"; "34" = "MullvadVPN.MullvadVPN"
    "35" = "Famatech.RadminVPN"; "36" = "CrystalDewWorld.CrystalDiskInfo"; "37" = "Microsoft.Sysinternals.RAMMap"
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
        Install-App @($appDictionary.Values)
        continue
    }
    
    # Separa as opções digitadas por vírgula
    $selectedNumbers = $choice -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    
    $appsToInstall = @()
    $invalidOptions = @()
    
    foreach ($num in $selectedNumbers) {
        if ($appDictionary.Contains($num)) {
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
