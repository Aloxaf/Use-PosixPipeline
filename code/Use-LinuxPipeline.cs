using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace Use_LinuxPipeline {
    public class Pipeline {
        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int dup(int oldfd);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int dup2(int oldfd, int newfd);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int pipe(int[] fd);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int open(string path, int oflag);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int close(int fd);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int execvp(string file, [MarshalAs(UnmanagedType.LPArray, ArraySubType=UnmanagedType.LPStr)] string[] argv);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern int fork();

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern void perror(string s);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern void exit(int status);

        [DllImport("libc.so.6", CallingConvention=CallingConvention.Cdecl)]
        public static extern void _exit(int status);

        public static int[] Run(int[] pipe_in, string[] cmd) {
            int[] pipe_out = new int[2];
            if (pipe(pipe_out) == -1) {
                perror("bad pipe_out");
                exit(1);
            }

            int pid;
            if ((pid = fork()) == -1) {
                perror("bad fork");
                exit(1);
            } else if (pid == 0) {
                // set input
                if (pipe_in != null) {
                    dup2(pipe_in[0], 0);
                    close(pipe_in[0]);
                    close(pipe_in[1]);
                }
                // set output
                dup2(pipe_out[1], 1);
                close(pipe_out[1]);
                close(pipe_out[0]);

                string[] argv = new string[cmd.Length + 1];
                cmd.CopyTo(argv, 0);
                argv[cmd.Length] = null;

                execvp(argv[0], argv);
                perror("there is something wrong with execlp");
                _exit(1);
            }

            if (pipe_in != null) {
                close(pipe_in[0]);
                close(pipe_in[1]);
            }

            return pipe_out;
        }

        public static int[] ReadFile(string filename) {
            int[] pipe_out = new int[2];
            if (pipe(pipe_out) == -1) {
                perror("bad pipe_out");
                exit(1);
            }

            int fd = open(filename, 0);
            dup2(fd, pipe_out[0]);
            close(fd);

            return pipe_out;
        }

        public static IEnumerable<byte> GetOutputAsBytes(int[] pipe_in) {
            int stdin_bak = dup(0);

            dup2(pipe_in[0], 0);
            close(pipe_in[0]);
            close(pipe_in[1]);

            Stream stdin  = Console.OpenStandardInput();
            // Stream stdout = Console.OpenStandardOutput();
            byte[] buffer = new byte[512];
            int count;
            while ((count = stdin.Read(buffer, 0, buffer.Length)) > 0) {
                for (int i = 0; i != count; i++) {
                    // stdout.Write(buffer, 0, count);
                    yield return buffer[i];
                }
            }
 
            dup2(stdin_bak, 0);
        }

        public static string GetOutputAsString(int[] pipe_in) {
            byte[] bytes = GetOutputAsBytes(pipe_in).ToArray();
            string s = Encoding.Default.GetString(bytes);
            return s.Remove(s.Length - 1, 1);
        }

        public static void WriteToStream(int[] pipe_in, Stream stream) {
            int stdin_bak = dup(0);

            dup2(pipe_in[0], 0);
            close(pipe_in[0]);
            close(pipe_in[1]);

            Stream stdin  = Console.OpenStandardInput();
            // Stream stdout = Console.OpenStandardOutput();
            byte[] buffer = new byte[512];
            int count;
            while ((count = stdin.Read(buffer, 0, buffer.Length)) > 0) {
                stream.Write(buffer, 0, count);
            }
 
            dup2(stdin_bak, 0);
        }

    }
}
