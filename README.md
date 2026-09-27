Linux System Calls Lab — Variant B
1. Environment
OS: Ubuntu Server 24.04.5 LTS
Architecture: ARM64 (Apple Silicon / VirtualBox)
Shell: Bash
Python: Python 3
System call tracing: strace
Static analysis: ShellCheck
2. Project Structure
linux-syscalls-lab/
├── report.sh
├── hello.py
├── README.md
├── trace.txt
├── cat_trace.txt
├── syscall_stats.txt
├── logs/
│   ├── app.log
│   └── other.log
└── data/
    └── sample.txt
3. report.sh

The Bash script accepts a directory and a log level (ERROR or WARN).

It counts messages by module, sorts the results in descending order, and supports the optional --top N argument.

The script checks whether the directory exists and validates the arguments.

Examples
./report.sh logs ERROR
./report.sh logs WARN
./report.sh logs ERROR --top 2
Validation
Missing arguments: usage information and exit code 1.
Missing directory: error message and exit code 1.
Invalid log level: error message and exit code 1.
Invalid top value: error message and exit code 1.
4. hello.py

The Python script opens a file in binary mode, reads its contents, and prints its size in bytes.

Example:

python3 hello.py data/sample.txt
5. System Call Analysis

The program was traced using:

strace -f -o trace.txt python3 hello.py data/sample.txt

Total system calls: 778

Read-related system calls (read and pread64): 76

The read-related count includes operations performed by the interpreter and its libraries, not only reads from the target file.

Why are there additional system calls?

Python is an interpreted language. Before executing the user script, the interpreter initializes its runtime environment, loads shared libraries, accesses configuration and module files, allocates memory, and performs other initialization operations.

These operations introduce additional system calls that are not directly related to reading the target file.
6. Comparison: cat vs Python
Program	Total system calls
cat	47
Python	778

Both programs read the same file: data/sample.txt.

Conclusion

The Python interpreter generally performs more system calls because it initializes its runtime environment and loads additional resources.

The cat utility performs a simpler task and typically requires fewer system calls.

The number of system calls alone does not determine total execution time or performance.
7. ShellCheck

The Bash script was checked using:

shellcheck report.sh

Result: no ShellCheck errors.

8. Control Questions
1. Why can't a user program access the disk directly?

User programs operate in user mode and cannot directly execute privileged hardware operations. They request file operations through system calls, which are handled by the operating system kernel.

The kernel controls access permissions, coordinates hardware operations, and protects system resources.

2. Which is more expensive: a function call or a system call, and why?

A normal function call generally has lower overhead because it usually stays within the same process and privilege level.

A system call requires a transition from user mode to kernel mode and additional operating-system handling.

Therefore, a system call is generally more expensive than an ordinary function call, although the actual cost depends on the operation and system architecture.
