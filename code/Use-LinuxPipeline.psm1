
# 运行一个外部程序, 可以通过管道连接
# eg. run cat /usr/bin/ls | run md5sum
function Start-LinuxProcess
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
        [System.String[]]$argv,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        return (,[Fuck.Pipeline]::Run($InputObject, $argv))
    }
}

# 将程序输出重定向到 PS, 非实时, 但可以捕获到变量
function RedirectTo-PS
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        Write-Output ([Fuck.Pipeline]::GetOutputAsString($InputObject))
    }
}

# 将程序输出重定向到文件, 相当于 >
function RedirectTo-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $fs = [System.IO.FileStream]::new($filename, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        [Fuck.Pipeline]::WriteToStream($InputObject, $fs)
        $fs.Close()
    }
}

# 将程序输出追加到文件, 相当于 >>
function AppendTo-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $fs = [System.IO.FileStream]::new($filename, [System.IO.FileMode]::Append)
        [Fuck.Pipeline]::WriteToStream($InputObject, $fs)
        $fs.Close()
    }
}

# 读取一个文件, 相当于 <
function Read-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename
    )
    process {
        return (,[Fuck.Pipeline]::ReadFile($filename))
    }
}

# 输出到控制台, 实时, 但不可捕获到控制台
# 一般用于实时输出监控
function Write-Console
{
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $stream = [Console]::OpenStandardOutput()
        [Fuck.Pipeline]::WriteToStream($InputObject, $stream)
    }
}

Set-Alias -Name 'run' -Value 'Start-LinuxProcess';
Set-Alias -Name '2ps' -Value 'RedirectTo-PS';
Set-Alias -Name 'stdin' -Value 'Read-File';
Set-Alias -Name 'stdout' -Value 'Write-Console';
Set-Alias -Name 'out2' -Value 'RedirectTo-File';
Set-Alias -Name 'add2' -Value 'AppendTo-File';

Export-ModuleMember -Function @('Start-LinuxProcess', 'RedirectTo-PS', 'Read-File', `
    'Write-Console', 'RedirectTo-File', 'AppendTo-File') `
    -Alias @('run', '2ps', 'stdin', 'stdout', 'out2', 'add2');

