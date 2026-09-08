# Caminho do arquivo temporario
 $urlInstalador = "https://raw.githubusercontent.com/Datasaferti/apps/main/instalador.ps1"
 $arquivoTemp = "$env:TEMP\instalador_datasafer.ps1"

Write-Host "Carregando o menu de instalacao DataSafer..." -ForegroundColor Cyan

try {
    # Baixa o instalador para a pasta TEMP
    Invoke-WebRequest -Uri $urlInstalador -OutFile $arquivoTemp -UseBasicParsing

    # Executa o instalador e espera ele ser encerrado (quando o usuario digitar 0)
    & $arquivoTemp
}
catch {
    Write-Host "Erro ao baixar ou executar o script. Verifique a conexao com a internet." -ForegroundColor Red
}
finally {
    # Assim que o instalador fecha (opcao 0), apaga o arquivo da pasta TEMP
    if (Test-Path $arquivoTemp) {
        Remove-Item $arquivoTemp -Force
        Write-Host "Arquivo temporario removido com sucesso do computador." -ForegroundColor Green
    }
}
