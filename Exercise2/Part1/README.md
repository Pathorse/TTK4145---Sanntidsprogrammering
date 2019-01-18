# Mutex and Channel basics

### What is an atomic operation?
<<<<<<< HEAD
<<<<<<< HEAD
> *Atomic operations in concurrent programming are program operations that run completely independently of any other process.*

### What is a semaphore?
> *In computer science, a semaphore is a variable or abstract data type used to control access to a common resource by multiple process in a concurrent system such as a multitasking operating system.*

### What is a mutex?
> *Mutex (mutual exclusion) is a property of concurrency control, which is institued for the purpose of preventing race conditions; it is the requirement that one thread of execution never enters its critical section at the same time that another concurrent thread of execution enters its own critical section.*

### What is the difference between a mutex and a binary semaphore?
> *Different processes can execute wait or signal operation on a semaphore. Mutexes have ownership, unlike semaphores.

Strictly speaking, a mutex is locking mechanism used to synchronize access to a resource. Only one task (can be a thread or process based on OS abstraction) can acquire the mutex. It means there is ownership associated with mutex, and only the owner can release the lock (mutex).

Semaphore is signaling mechanism (“I am done, you can carry on” kind of signal). For example, if you are listening songs (assume it as one task) on your mobile and at the same time your friend calls you, an interrupt is triggered upon which an interrupt service routine (ISR) signals the call processing task to wakeup.

https://www.geeksforgeeks.org/mutex-vs-semaphore/*

### What is a critical section?
> *In simple terms a critical section is group of instructions/statements or region of code that need to be executed atomically, such as accessing a resource.*

### What is the difference between race conditions and data races?
 > *A race condition is a flaw that occurs when the timing or ordering of events affects a program’s correctness. Generally speaking, some kind of external timing or ordering non-determinism is needed to produce a race condition; typical examples are context switches, OS signals, memory operations on a multiprocessor, and hardware interrupts
 
 A data race happens when there are two memory accesses in a program where both:
    - target the same location
    - are performed concurrently by two threads
    - are not reads
    - are not synchronization operations
    https://blog.regehr.org/archives/490* 


### List some advantages of using message passing over lock-based synchronization primitives.
> *It's a pretty simple difference. In a shared memory model, multiple workers all operate on the same data. This opens up a lot of the concurrency issues that are common in parallel programming.

Message passing systems make workers communicate through a messaging system. Messages keep everyone seperated, so that workers cannot modify each other's data.

By analogy, lets say we are working with a team on a project together. In one model, we are all crowded around a table, with all of our papers and data layed out. We can only communicate by changing things on the table. We have to be careful not to all try to operate on the same piece of data at once, or it will get confusing and things will get mixed up.

In a message passing model, we all sit at our desks, with our own set of papers. When we want to, we can pass a paper to someone else as a "message", and that worker can now do what they want with it. We only ever have access to whatever we have in front of us, so we never have to worry that someone is going to reach over and change one of the numbers while we are in the middle of summing them up.*

### List some advantages of using lock-based synchronization primitives over message passing.
> *Cons of Shared Objects (Pros od Message Passing):

The state of Mutable/Shared objects are harder to reason about in a context where multiple threads run concurrently.
Synchronizing on a Shared Objects would lead to algorithms that are inherently non-wait free or non-lock free.
In a multiprocessor system, A shared object can be duplicated across processor caches. Even with the use of Compare and swap based algorithms that doesn't require synchronization, it is possible that a lot of processor cycles will be spent sending cache coherence messages to each of the processors.
A system built of Message passing semantics is inherently more scalable. Since message passing implies that messages are sent asynchronously, the sender is not required to block until the receiver acts on the message.
Pros of Shared Objects (Cons of Message Passing):

Some algorithms tend to be much simpler.
A message passing system that requires resources to be locked will eventually degenerate into a shared object systems. This is sometimes apparent in Erlang when programmers start using ets tables etc. to store shared state.
If algorithms are wait-free, you will see improved performance and reduced memory footprint as there is much less object allocation in the form of new messages.*
=======
> *An uninterruptable operation.*

### What is a semaphore?
> *An integer value controlling access to a resource. All threads desiring to use the resource tries to decrement the value, and must wait if the result
	of the decrement is negative. The integer value is signaled (incremented) when it is available for one more user. If there are threads waiting for 
	the resource when it is signaled, one of them is given access.*

### What is a mutex?
> *A mutex is a mutually exclusive way of protecting a resource. Only one task can access the resource at the same time.
	A mutex is either locked or unlocked. Only the owner can unlock the mutex.*

### What is the difference between a mutex and a binary semaphore?
> *A mutex is a lock providing synchronization via ownership of resources. A binary semaphore is typically used by a thread to signal another thread that something has happened.*

### What is a critical section?
> *A sequence of statements that must (appear) be executed indivisibly. Therefore, a critical section should be implemented as an atomic operation.*

### What is the difference between race conditions and data races?
 > *A race condition causes the result of several operations (a program) to be dependent on the order of execution. 
	Data races is when two or more processes try to access a memory location and: the operation is not read, *

### List some advantages of using message passing over lock-based synchronization primitives.
> *When you do not share variables, you will not face the problem of two threads accessing the same variable at the same time.
	Synchronization is not needed across processors when using message passing.*

### List some advantages of using lock-based synchronization primitives over message passing.
> *Lock-based is more "low-level" programmed, giving better performance if done correctly.*
>>>>>>> Håvard
