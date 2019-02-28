# Use-LinuxPipeline

[Use-RawPipeline](https://github.com/GeeLaw/PowerShellThingies/tree/master/modules/Use-RawPipeline) 的 Linux 版

<s>(pwsh 除了管道艹蛋了点外还是挺香的, 尤其是可读性比 bash 不知道高到哪里去了)</s>

<s>(但是这艹蛋的管道起码能劝退 90% 对它有兴趣的 Linux 用户)</s>

## 原理

调用 Linux 库函数 pipe 实现管道, pwsh 的管道只用来传递文件描述符. (简单粗暴

## 用法 (基本和 Use-RawPipeline 一样)

| bash | PowerShell (with Use-LinuxPipeline) |
| --- | --- |
| `base64 -d < file` | `stdin file \| run base64 -d | 2ps` |
| `cat foo > bar` | `run cat foo \| out2 bar` |
| `cat foo >> bar` | `run cat foo |\ add2 bar` |
| `cat file \| md5sum` | `run cat file | run md5sum \| 2ps` |
| `cat file \| grep re` | `run cat BIGFILE \| run grep re \| stdout` |

2ps 和 stdout 的区别:

- 2ps 会等待所有输出完成后返回, 而且输出可以被捕获
- stdout 会实时输出, 但输出不可以被捕获

和 Use-RawPipeline 的区别:

- `run xxx` 即使后面不接 `| 2ps`, `| run xxx` 之类的命令也会执行

## 安装 (outdated)

因为还没经过充分测试所以只能这样安装

```bash
git clone "https://github.com/Aloxaf/Use-LinuxPipeline"
cp -r ./Use-LinuxPipeline ~/.local/share/powershell/Modules/Use-LinuxPipeline
pwsh -c "Import-Module -Name Use-LinuxPipeline"
```
