# Reasons for concurrency and parallelism


To complete this exercise you will have to use git. Create one or several commits that adds answers to the following questions and push it to your groups repository to complete the task.

When answering the questions, remember to use all the resources at your disposal. Asking the internet isn't a form of "cheating", it's a way of learning.

 ### What is concurrency? What is parallelism? What's the difference?
 > *Concurrency is the composition of independently executing processes, while parallelism is the simultaneous execution of (possibly related) computations. It is possible for an application to be both concurrent and parallel, which means that it processes multiple tasks concurrently in multi-core CPU at the same time.*
 
 ### Why have machines become increasingly multicore in the past decade?
 > *Since the rate of clock speed improvements slowed, increasing use of parallel computing in the form om multi-core processors has been pursued to improve overall processing performance.*
 
 ### What kinds of problems motivates the need for concurrent execution?
 (Or phrased differently: What problems do concurrency help in solving?)
 > *Concurrency helps solving problems which can be separated into different parts and executed out-of-order or in partial order, without affecting the final outcome.*
 
 ### Does creating concurrent programs make the programmer's life easier? Harder? Maybe both?
 (Come back to this after you have worked on part 4 of this exercise)
 > *Your answer here*
 
 ### What are the differences between processes, threads, green threads, and coroutines?
 > *A process is an executing instance of an application. A thread is a path of execution within a process. Also a process can contain multiple threads. It is however important to note that a thread can do anything a process can do.
 The essential difference between a thread and a process is the work that each one is used to accomplish. Threads are used for small tasks, whereas processes are used for more 'heavyweight' tasks - basically the execution of applications.
 A green thread is a thread that are scheduled by a runtime library or a virtual machine (VM) instead of natively by the underlying operating system OS. Green threads can be used to simulate multi-threading on platforms that dont provide that capability. They are managed in user space instead of kernel space
 A coroutine is similar to a thread (in the sense of multithreading): it is a line of execution, with its own stack, its own local variables and its own instruction pointer; but it shares global variables and mostly anything else with other coroutines. The main difference between threads and coroutines is that, conceptually (or literally in a multiprocessor machine), a program with threads runs several threads in parallel. Coroutines, on the other hand are collaborative: at any given time, a program with coroutines is running only one of its coroutines, and this running coroutine suspends it execution only when it eplicity requests to be suspended.*
 
 ### Which one of these do `pthread_create()` (C/POSIX), `threading.Thread()` (Python), `go` (Go) create?
 > *pthread_create() - creates a new thread
 threading.Thread() - a class that represents a thread of control
'go' - is a tool for managing Go source code*
 
 ### How does pythons Global Interpreter Lock (GIL) influence the way a python Thread behaves?
 > *The Python Global Interpreter Lock or GIL, in simple words, is a mutex (or a lock) that allows only one thread to hold the control of the Python interpreter.
 This means that only one thread can be in a state of execution at any point in time.The impact of the GIL isnt visible to developers who execute singlethreaded programs, but can be a performance bottleneck in CPU-bound and multithreaded code.*
 
 ### With this in mind: What is the workaround for the GIL (Hint: it's another module)?
 > *Decouple your I/O threads from the CPU bound threads using a message queue.*
 
 ### What does `func GOMAXPROCS(n int) int` change? 
 > *func GOMAXPROCS(n int) int - sets the maximum number of CPUs that can be executing simultaneously and returns the previous setting.*
