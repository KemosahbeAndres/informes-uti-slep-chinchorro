<#
.SYNOPSIS
  init.ps1 — Instalador de doctyp (generador de informes Typst · SLEP Chinchorro) para Windows.

.DESCRIPTION
  Equivalente en PowerShell del script `init` de Linux. Comprueba Python 3 y Typst, instala las
  fuentes oficiales (Museo Sans + gobCL) para el usuario, y crea envoltorios `.cmd` del comando
  (doctyp + alias ty/tp/dt) en una carpeta de scripts, que se añade al PATH del usuario.

  En Windows no se usan symlinks (requieren privilegios o Developer Mode): en su lugar se generan
  pequeños lanzadores `.cmd` que invocan `python doctyp.py`. Así el comando funciona desde
  cualquier carpeta, igual que en Linux.

  Lo que NO se puede automatizar (instalar Python/Typst sin un gestor) se reporta con
  instrucciones, sin abortar.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\init.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Carpetas de destino (perfil del usuario; no requieren administrador).
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BinDir  = Join-Path $env:USERPROFILE 'bin'              # lanzadores .cmd (se añade al PATH)
$FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'  # fuentes por-usuario
$Aliases = @('doctyp', 'ty', 'tp', 'dt')

function Info($m) { Write-Host "==> $m" -ForegroundColor Blue }
function Ok($m)   { Write-Host "  OK $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  ! $m"  -ForegroundColor Yellow }
function Err($m)  { Write-Host "ERROR: $m" -ForegroundColor Red }

# Resuelve el ejecutable de Python (py launcher si existe; si no, python).
function Get-Python {
  foreach ($c in @('py', 'python', 'python3')) {
    $cmd = Get-Command $c -ErrorAction SilentlyContinue
    if ($cmd) {
      # `py` necesita -3 para forzar Python 3; los demás van directos.
      if ($c -eq 'py') { return @{ Exe = $cmd.Source; Args = '-3' } }
      return @{ Exe = $cmd.Source; Args = '' }
    }
  }
  return $null
}

# --------------------------------------------------------------------------
# 1) Python 3
# --------------------------------------------------------------------------
Info 'Comprobando Python 3...'
$py = Get-Python
if ($py) {
  $ver = & $py.Exe $py.Args '--version' 2>&1
  Ok "Python presente: $ver"
} else {
  Err 'No se encontró Python 3.'
  Warn 'Instálalo desde https://www.python.org/downloads/ (marca "Add python.exe to PATH"),'
  Warn 'o con winget:  winget install Python.Python.3.12'
}

# --------------------------------------------------------------------------
# 2) Typst
# --------------------------------------------------------------------------
Info 'Comprobando Typst...'
if (Get-Command typst -ErrorAction SilentlyContinue) {
  Ok "Typst presente: $(typst --version)"
} else {
  Warn 'Typst no está instalado. Instálalo con uno de:'
  Warn '  winget install Typst.Typst'
  Warn '  scoop install typst'
  Warn '  cargo install typst-cli'
  Warn '  o binario desde https://github.com/typst/typst/releases'
}

# --------------------------------------------------------------------------
# 3) Fuentes oficiales (Museo Sans + gobCL)
# --------------------------------------------------------------------------
Info "Instalando fuentes oficiales en $FontDir..."
New-Item -ItemType Directory -Force -Path $FontDir | Out-Null
$copied = 0
foreach ($d in @((Join-Path $RepoDir 'museo-sans'), (Join-Path $RepoDir 'GobCLFontsFiles'))) {
  if (-not (Test-Path $d)) { continue }
  foreach ($f in Get-ChildItem -Path $d -Include '*.otf', '*.ttf' -File -Recurse -ErrorAction SilentlyContinue) {
    Copy-Item -Force $f.FullName (Join-Path $FontDir $f.Name)
    $copied++
  }
}
if ($copied -gt 0) {
  Ok "Fuentes copiadas ($copied archivos)."
  Warn 'En Windows, para que las apps reconozcan fuentes por-usuario puede hacer falta'
  Warn 'reiniciar la sesión. Typst las usa vía --font-path sin necesidad de instalarlas.'
} else {
  Warn 'No se encontraron archivos de fuente en el repositorio.'
}

# --------------------------------------------------------------------------
# 4) Lanzadores .cmd del comando (doctyp + alias)
# --------------------------------------------------------------------------
Info "Creando lanzadores en $BinDir..."
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$script = Join-Path $RepoDir 'doctyp.py'
# Comando Python a invocar dentro del .cmd: usa `py -3` si está, si no `python`.
if ($py -and $py.Exe -like '*py.exe') { $pyCall = 'py -3' } else { $pyCall = 'python' }
foreach ($n in $Aliases) {
  $cmdPath = Join-Path $BinDir "$n.cmd"
  # %* reenvía todos los argumentos al script. Comillas por si la ruta tiene espacios.
  @(
    '@echo off'
    "$pyCall `"$script`" %*"
  ) -join "`r`n" | Set-Content -Encoding ASCII -Path $cmdPath
  Ok "$n -> $script"
}

# --------------------------------------------------------------------------
# 5) Datos del autor (settings.json -> local.author)
# --------------------------------------------------------------------------
# Se piden interactivamente y se guardan globalmente; al crear documentos, doctyp los usa por
# defecto. Se delega en el propio script (config-author). Volver a ejecutar init.ps1 permite
# cambiarlos (en blanco se mantiene el valor actual).
if ($py) {
  Info 'Configurando datos del autor (se guardan en settings.json)...'
  if ($py.Args) { & $py.Exe $py.Args $script 'config-author' }
  else          { & $py.Exe        $script 'config-author' }
} else {
  Warn 'Omito la configuración del autor (sin Python). Configúralo luego con:  doctyp config-author'
}

# --------------------------------------------------------------------------
# 6) PATH del usuario
# --------------------------------------------------------------------------
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -and ($userPath.Split(';') -contains $BinDir)) {
  Ok "$BinDir ya está en el PATH del usuario."
} else {
  $newPath = if ([string]::IsNullOrEmpty($userPath)) { $BinDir } else { "$userPath;$BinDir" }
  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
  Ok "$BinDir añadido al PATH del usuario."
  Warn 'Abre una terminal nueva para que el PATH se actualice.'
}

Write-Host ''
Ok 'Instalación completada. En una terminal nueva, prueba:  doctyp list'
