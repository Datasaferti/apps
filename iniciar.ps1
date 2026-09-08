# Gera um número aleatório para forçar o GitHub a entregar a versão mais recente e ignorar o cache
 $versaoAleatoria = Get-Random
 $urlInstalador = "https://raw.githubusercontent.com/Datasaferti/apps/main/instalador.ps1?v=$versaoAleatoria"
 $arquivoTemp = "$env:TEMP\instalador_datasafer.ps1"

Write-Host "Baixando a versão mais recente do instalador DataSafer..." -ForegroundColor Cyan

# Apaga qualquer arquivo antigo que tenha ficado travado na pasta TEMP de execuções anteriores
if (Test-Path $arquivoTemp) {
    Remove-Item $arquivoTemp -Force -ErrorAction SilentlyContinue
}

try {
    # Baixa o instalador atualizado para a pasta TEMP
    Invoke-WebRequest -Uri $urlInstalador -OutFile $arquivoTemp -UseBasicParsing

    # Executa o instalador
    & $arquivoTemp
}
catch {
    Write-Host "Erro ao baixar ou executar o script." -ForegroundColor Red
}
finally {
    # Pausa de 1 segundo para garantir que o processo terminou
    Start-Sleep -Seconds 1
    
    # Apaga o arquivo da pasta TEMP assim que o menu encerra
    if (Test-Path $arquivoTemp) {
        Remove-Item $arquivoTemp -Force -ErrorAction SilentlyContinue
        Write-Host "Obrigado por usar nossos serviços." -ForegroundColor Green
    }
}
