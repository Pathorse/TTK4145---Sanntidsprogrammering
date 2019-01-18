# Mutex and Channel basics

### What is an atomic operation?
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
