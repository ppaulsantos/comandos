Write-Host "Limpando cache do NuGet..."
dotnet nuget locals all --clear

$m2Path = "$env:USERPROFILE\.m2\repository"
if (Test-Path $m2Path) {
    Write-Host "Limpando repositorio local do Maven ($m2Path)..."
    Remove-Item -Recurse -Force -Confirm:$false $m2Path
} else {
    Write-Host "Repositorio Maven nao encontrado em $m2Path, pulando."
}

Write-Host "Limpeza concluida."
