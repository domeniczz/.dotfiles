# Resolve a Python interpreter with paramiko installed, preferring conda.
# Prints the interpreter path as the last line on stdout so the caller can
# capture it, e.g.:
#   $PYTHON = (powershell -ExecutionPolicy Bypass -File scripts\setup_env.ps1 | Select-Object -Last 1)
# All diagnostic output goes to stderr; stdout carries only the final path.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReqFile = Join-Path $ScriptDir 'requirements.txt'
$EnvName = 'skill-ssh-operation'

function Write-Diag {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

function Invoke-ToStderr {
    param(
        [string]$FilePath,
        [string[]]$Arguments
    )
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $FilePath @Arguments 2>&1 | ForEach-Object {
            Write-Diag ($_.ToString())
        }
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prevPref
    }
}

$condaCmd = Get-Command conda -ErrorAction SilentlyContinue
if ($condaCmd) {
    Write-Diag "conda found, using/creating env '$EnvName'"
    $envList = & $condaCmd.Source env list 2>$null
    $envExists = $envList | Where-Object { $_ -match "^\s*$([regex]::Escape($EnvName))\s" }
    if (-not $envExists) {
        Write-Diag "creating conda env '$EnvName'"
        $rc = Invoke-ToStderr -FilePath $condaCmd.Source -Arguments @('create', '-y', '-n', $EnvName, 'python=3.11')
        if ($rc -ne 0) {
            Write-Diag "ERROR: conda env creation failed. If the error above mentions Terms of Service, ask the user to run: conda tos accept"
            exit 1
        }
    }

    $pyPath = (& $condaCmd.Source run -n $EnvName python -c "import sys; print(sys.executable)" 2>$null | Select-Object -Last 1)
    if ($LASTEXITCODE -ne 0 -or -not $pyPath) {
        Write-Diag "ERROR: failed to resolve Python interpreter in conda env '$EnvName'."
        exit 1
    }
    $pyPath = $pyPath.Trim()

    $rc = Invoke-ToStderr -FilePath $pyPath -Arguments @('-m', 'pip', 'install', '-q', '-r', $ReqFile)
    if ($rc -ne 0) {
        Write-Diag "ERROR: pip install failed in conda env '$EnvName'."
        exit 1
    }

    Write-Output $pyPath
    exit 0
}

function Find-WorkingPython {
    $candidates = @(
        @{ Name = 'python'; PrefixArgs = @() },
        @{ Name = 'py'; PrefixArgs = @('-3') },
        @{ Name = 'python3'; PrefixArgs = @() }
    )
    foreach ($candidate in $candidates) {
        $cmd = Get-Command $candidate.Name -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }
        # Skip Microsoft Store WindowsApps alias stub if it does not actually run Python
        $testArgs = $candidate.PrefixArgs + @('-c', 'import sys; print(sys.executable)')
        $resolved = (& $cmd.Source @testArgs 2>$null | Select-Object -Last 1)
        if ($LASTEXITCODE -eq 0 -and $resolved -and (Test-Path $resolved.Trim())) {
            return @{
                Exe = $cmd.Source
                PrefixArgs = $candidate.PrefixArgs
                ResolvedPath = $resolved.Trim()
            }
        }
    }
    return $null
}

$pyInfo = Find-WorkingPython
if ($pyInfo) {
    $cacheRoot = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $HOME '.cache' }
    $venvDir = Join-Path (Join-Path $cacheRoot 'skill-ssh-operation') 'venv'
    $venvPython = Join-Path (Join-Path $venvDir 'Scripts') 'python.exe'

    Write-Diag "no conda; using python venv at $venvDir"
    if (-not (Test-Path $venvPython)) {
        $parentDir = Split-Path -Parent $venvDir
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        $venvArgs = $pyInfo.PrefixArgs + @('-m', 'venv', $venvDir)
        $rc = Invoke-ToStderr -FilePath $pyInfo.Exe -Arguments $venvArgs
        if ($rc -ne 0 -or -not (Test-Path $venvPython)) {
            Write-Diag "ERROR: failed to create Python venv at $venvDir."
            exit 1
        }
    }

    $rc = Invoke-ToStderr -FilePath $venvPython -Arguments @('-m', 'pip', 'install', '-q', '-r', $ReqFile)
    if ($rc -ne 0) {
        Write-Diag "ERROR: pip install failed in Python venv at $venvDir."
        exit 1
    }

    Write-Output $venvPython
    exit 0
}

Write-Diag "ERROR: neither conda nor python is available on this system. Cannot run the ssh-operation skill."
exit 1
