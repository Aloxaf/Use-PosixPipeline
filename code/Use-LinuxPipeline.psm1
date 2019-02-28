
# 运行一个外部程序, 可以通过管道连接
# eg. run cat /usr/bin/ls | run md5sum
function Fork-Process
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
        [System.String[]]$argv,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        return (,[Use_LinuxPipeline.Pipeline]::Run($InputObject, $argv));
    }
}

# 将程序输出重定向到 PS, 非实时, 但可以捕获到变量
function PipeTo-PS
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        Write-Output ([Use_LinuxPipeline.Pipeline]::GetOutputAsString($InputObject));
    }
}

# 将程序输出重定向到文件, 相当于 >
function PipeOverwrite-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $fs = [System.IO.FileStream]::new($filename, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write);
        [Use_LinuxPipeline.Pipeline]::WriteToStream($InputObject, $fs);
        $fs.Close();
    }
}

# 将程序输出追加到文件, 相当于 >>
function PipeAppend-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $fs = [System.IO.FileStream]::new($filename, [System.IO.FileMode]::Append);
        [Use_LinuxPipeline.Pipeline]::WriteToStream($InputObject, $fs);
        $fs.Close();
    }
}

# 读取一个文件, 相当于 <
function PipeFrom-File
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$filename
    )
    process {
        return (,[Use_LinuxPipeline.Pipeline]::ReadFile($filename));
    }
}

# 输出到控制台, 实时, 但不可捕获到控制台
# 一般用于实时输出监控
function PipeTo-Console
{
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [System.Int32[]]$InputObject = $null
    )
    process {
        $stream = [Console]::OpenStandardOutput();
        [Use_LinuxPipeline.Pipeline]::WriteToStream($InputObject, $stream);
    }
}

Set-Alias -Name 'run' -Value 'Fork-Process';
Set-Alias -Name '2ps' -Value 'PipeTo-PS';
Set-Alias -Name 'stdin' -Value 'PipeFrom-File';
Set-Alias -Name 'stdout' -Value 'PipeTo-Console';
Set-Alias -Name 'out2' -Value 'PipeOverwrite-File';
Set-Alias -Name 'add2' -Value 'PipeAppend-File';

Export-ModuleMember -Function @('Fork-Process', 'PipeTo-PS', 'PipeFrom-File', `
    'PipeTo-Console', 'PipeOverwrite-File', 'PipeAppend-File') `
    -Alias @('run', '2ps', 'stdin', 'stdout', 'out2', 'add2');

