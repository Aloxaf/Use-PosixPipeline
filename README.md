# Use-PosixPipeline

[Use-RawPipeline](https://github.com/GeeLaw/PowerShellThingies/tree/master/modules/Use-RawPipeline) 的 POSIX 版 (说是 POSIX 其实现在只支持 Linux

<s>(pwsh 除了管道艹蛋了点外还是挺香的, 尤其是可读性比 bash 不知道高到哪里去了)</s>

<s>(但是这艹蛋的管道起码能劝退 90% 对它有兴趣的 Linux 用户)</s>

## 原理

调用 Linux 库函数 pipe 创建管道, 用 execvp 创建进程, 用 dup2 重定向输入输出

pwsh 的管道只用来传递文件描述符. (简单粗暴

## 基本用法 (兼容大部分 Use-RawPipeline 参数)

| bash | PowerShell (with Use-PosixPipeline) |
| --- | --- |
| `git commit-tree 01d1 -p HEAD < msg` | `stdin msg \| run git commit-tree 01d1 -p HEAD \| 2ps` |
| `git show HEAD:README.md > temp` | `run git show HEAD:README.md \| out2 temp` |
| `git cat-file blob b428 >> temp` | `run git cat-file blob b428 \| add2 temp` |
| `git cat-file blob b428 \| xxd` | `run git cat-file blob b428 \| run xxd \| 2ps` |

和 Use-RawPipeline 的区别:

- `run xxx` 即使后面不接 `| 2ps`, `| run xxx` 之类的命令也会执行
- `run` 增加了 `-PipeError` 开关, 相当于 `2>&1`
- `2ps` 只有 `-Encoding` 开关, 去掉了 `-CommonEncoding` 开关, 且默认 UTF-8