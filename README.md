# TTK4145-Real-time Programming
<meta name ="author" content="Paal A. S. Thorseth">

**Below you find notes regarding important topics in Real-time Programming. The topics are based on relevant exams for TTK4145 at NTNU.**

## List of topics
1. [Topic 1 - *Fault tolerance*](#of1)
2. [Topic 2 - *Acceptance tests*](#of2)
3. [Topic 3 - *Real-Time Programming*](#of3)
4. [Topic 4 - *Concurrency*](#of4)
5. [Topic 5 - *Synchronization*](#of5)
6. [Topic 6 - *Race conditions*](#of6)
7. [Topic 7 - *Inheritance Anomaly*](#of7)
8. [Topic 8 - *Priority ceiling protocol*](#of8)
9. [Topic 9 - *Scheduling*](#of9)
10. [Topic 10 - *Specific language features*](#of10)



<a name="of1"></a>
## Topic 1 - Fault tolerance

**Fault tolerance** is the property that enables a system to continue operating properly in the event of the failure of (or one or more faults within) some of its components. If its operating quality decreases at all, the decrease is proportional to the severity of the failure, as compared to a naively designed system, in which even a small failure can cause total breakdown. Fault tolerance is particularly sought after in high-availability or life-critical systems. The ability of maintaining functionality when portions of a system break down is referred to as **graceful degradation**.

A **fault-tolerant design** enables a system to continue its intended operation, possibly at a reduced level, rather than failing completely, when some part of the system fails. The term is most commonly used to describe *computer systems* designed to continue more or less fully operational with, perhaps, a reduction in throughput or an increase in response time in the event of a partial failure. That is, the system as a whole is not stopped due to problems in either *hardware* or *software*. *Software brittleness* is the oppositve of *robustness*. *Resilient Networks* continue to transmit data despite the failure of some links or nodes.

A system with high **failure transparency** will alert users that a component failure has occured, even if it continues to operate with full performance, so that failure can be repaired or imminent complete failure anticipated.

Within the scope of an *individual system*, fault tolerance can be achieved by anticipating exceptional conditions and building the system to cope with them, and, in general, aiming for **self-stabilization** so that the system converges towards an error-free state. However, if the consequences of a system failure are catastrophic, or the cost of making it sufficiently reliable is very high, a better solution may be to use some form of duplication. In any case, if the consequence of a system failure is so catastrophic, the system must be able to use reversion to fall back to a safe mode.


Below you find a number of choices to be examined to determine which components should be fault tolerant:
- **How critical is the component?** In a car, the radio is not critical, so this component has less need for fault tolerance.
- **How likely is the component to fail?** Some components, like the drive shaft in a car, are not likely to fail, so no fault tolerance is needed.
- **How expensive is it to make the component fault tolerant?** Requiring a redundant car engine, for example, would likely be too expensive both economically and in terms of weight and space, to be considered.

### Requirements
The basic characteristics of fault tolerance require:
1. **No single point of failure** - If a system experiences a failure, it must continue to operate without interruption during the repair process.
2. **Fault isolation to the failing component** - When a failure occurs, the system must be able to isolate the failure to the offending component. This requires the addition of dedicated failure detection mechanisms that exist only for the purpose of fault isolation. Recovery of a fault condition requires classifying the fault or failing component.
3. **Fault containment to precent propagation of the failure** - Some failure mechanisms can cause a system to fail by propagating the failure to the rest of the system.
4. **Availability of reversion modes**

### Notes based on answers for exam questions

**Fault Tolerance** encompasses more than just minimizing the number of bugs in the system, it should provide a system that behaves as specified *even though* there are bugs there.

Testing your system is seen as an insufficient technique for making a **fault tolerant system** as **fault tolerance** is always about being tolerant to the bug that is not (yet) discovered.



<a name="of2"></a>
## Topic 2 - Acceptance tests

In engineering and its various subdisciplines **acceptance testing** is a test conducted to determine if the requirements of a specification or contract are met. 

In *software testing* the ISTQB(International Software Testing Qualifications Board) defines **acceptance testing** as:

>Formal testing with respect to user needs, requirements, and business processes conducted to determine whether or not a system satisfies the acceptance criteria and to enable the user, customers or other authorized entity to determine whether or not to accept the system.


### Types of acceptance testing
- **User acceptancte testing - UAT**
    - This may include factory acceptance testing (FAT), i.e. the teseting done by a vendor before the product or system is moved to its destination site, after which site acceptance testing (SAT) may be preformed by the users at the site.
- **Operational acceptance testing - OAT**
    - Also known as operational readiness testing, this refers to the chechking done to a system to ensure that processes and procedures are in place to allow the system to be used and maintained. This may include checks done to back-up facilities, procedures for disaster recovery, training for end users, maintenance procedures, and security procedures. 
- **Contract and regulation acceptance testing**
    - In contract acceptance testing, a system is tested against acceptance criteria as documented in a contract, before the system is accepted. In regulation acceptance testing, a system is tested to ensure it meets governmental, legal and safety standards.

### Notes based on answers for exam questions

**Fault tolerance** does not require the system to be fault free. We use **acceptance testing** for detecting whether anything is wrong, not to identify *any fault*.

**Learn-by-heart list from the book - Examples of what one can test for when making acceptance tests**
- Replication checks
- Timing checks
- Reversal checks
- Coding checks
- Reasonableness checks
- Structural checks
- Dynamic Reasonableness checks



<a name="of3"></a>
## Topic 3 - Real-Time Programming

In *computer science*, **real-time computing (RTC)**, or **reactive computing** describes hardware and software systems subject to a "real-time constraint", for example fomr event to system response. **Real-time programs** must guarantee response within specified time constraints, often referred to as "deadlines". The correctness of these types of systems depends on their temporal aspects as well as their functional aspects. **Real-time responses** are often understood to be in the order of milliseconds, and sometimes microseconds. A system not specified as operating in real time cannot usually *guarantee* a response within any timeframe, although *typical* or *expected* response times may be given.

**Real-time software** may use one or more of the following:
- *Synchronous programming languages*
- *Real-time operating systems*
- *Real-time networks*
each of which provide essential frameworks on which to build a real-time software application. 

System used for *mission critical* applications must be real-time, such as for control of fly-by-wire aircraft, or anti-lock brakes on a vehicle, which must produce maximum deceleration but intermittently stop braking to prevent skidding.

**Real-time systems**, as well as their deadlines, are classified by the consequence of missing a deadline:
- *Hard* - missing a deadline is a total system failure.
- *Firm* - infrequent deadline misses are tolerable, but may degrade the system's quality of service. The usefulness of a result is zero after its deadline.
- *Soft* - the usefulness of a result degrades after its deadline, thereby degranding the system's quality of service.

### Notes based on answers for exam questions

**Priorities** are very important in real-time programming to be able to reason on timing/execution behaviour of our program and/or to make schedulability proofs, we need predictability. Priorities is what make us able to predict which thread is running in any given situation.

Making a **upper bound of execution time** relates both to design and estimates.
- *Design*
    - No recursion
    - No algorithms with undeterminable execution time
    - No unbounded size data structures nor dynamic datastructures at all
    - No unbounded input data dependencies
- *Estimation* 
    1. Having sequences of predictable time assembly instructions enclosed by looping with known max bounds which means we can multiply and sum.
    2. We can run the system at a worstcase scenario, measure time of execution and add some buffer to ensure a safe *uppder bound*.

The consequences of *not being able to tell the timing* from code is terrible in a maintenance perspective, yielding the need for a re-analysis of the whole system to ensure that executions are within given time frames. An update could in the worst case lead to worse timing behaviour than previously. 


We can prove that deadlines in a system will be satisfied by doing a **response time analysis**, that is for each thread we can calculate its worst case **response time** from its max execution time and the number of times it can be interrupted by higher-priority threads. Further **utilization-based schedulability tests** are needed. This test is bsed on a formula which guarantees schedulability for **N** threads if the threads have *rate-monotonic priorities* and the sum of **utilizations** are less than a given number (dependent only on **N**).

<a name="of4"></a>
## Topic 4 - Concurrency

In *computer science*, **concurrency** is the ability of different parts of units of a program, algorithm, or problem to be executed out-of-order or in partial order, without affecting the final outcome. This allows for parallel execution of the concurrent units, which can significantly improve overall speed of the execution in multi-processor and multi-core systems. In more technical terms, **concurrency** refers to the decomposability property of a program, algorithm, or problem into order-independet or partially-ordered components or units.

Because computations in a **concurrent system** can interact with each other while being executed, the number of possible execution paths in the system can be extremely large, and the resulting outcome can be indeterminate. **Concurrent** use of shared resources can be a source of indeterminacy leading to issues such as deadlocks, and resource starvation.

>Design of concurrent systems often entails finding reliable techniques for coordinating their execution, data exchange, memory allocation, and execution scheduling to minimize response time and maximize throughput.

### Critical section

In **concurrent programming**, concurrent accesses to *shared resources* can lead to unexpected or erroneous behavior, so parts of the program where the *shared resource* is accessed are protected. This protected section is the **critical section**. It cannot be executed by more than one process at a time. Typically, the **critical section** accesses a shared resource, such as a data structure, a peripheral device, or a network connection, that would not operate correctly in the context of multiple **concurrent** accesses.

Different codes or processes may consist of the same variable or other resources that need to be read or written but whose results depend on the order in which the actions occur. For example, if a variable `x` is to be read by process **A**, and process **B** has to write to the same variable `x` at the same time, process **A** might get either the old or new value of `x`:

```
// Process A
.
.
b = x + 5;    // instruction executes at time = Tx
.
```

```
// Process B
.
.
x = 3 + z;    // instruction executes at time = Tx
.
```

In cases like these, a critical sextion is important. In the above case, if **A** needs to read the updated value of **x**, executing Process **A** and Process **B** at the same time may not give required results. To prevent this, variable `x` is protected by a critical sextion. First, **B** gets the access to the section. Once **B** finishes writing the value, **A** gets the access to the critical section and variable `x` can be read.

![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/Critical_section_fg.jpg "Figure 1: Flow graph depiciting need for critical section.").

#### Implementation of critical sections

The implementation of **critical sections** vary among different operating systems.

A **critical sections** will usually terminate in finite time, and a thread, task, or process will have to wait for a fixed time to enter it (**bounded waiting**). To ensure exclusive use of critical sections some synchronization mechanism is required at the entry and exit of the program.

**Critical section** is a piece of the program that requires **mutual exclusion** of access.

![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/Locks_and_critical_sections.jpg "Figure 2: Locks and critical sections in multiple threads.").

As shown in Figure 2, in the case of **mutual exclusion** (mutex), one threads blocks a **critical section** by using locking techniques when it needs to access the shared resource and other threads have to wait to get their turn to enter into the section. This prevents conflicts when two or more threads share the same memory space and want to access a common resource.

### Mutual exclusion

In *computer science*, **mutual exclusion** is a property of **concurrency control**, which is institued for the purpose of preventing **race conditions**; it is the requirement that one thread of execution never enters its **critical section** at the same time that another **concurrent** thread of execution enters its own **critical section**.

![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/1024px-Mutual_exclusion_example_with_linked_list.png "Two nodes, *i* and *i+1*, being removed simultaneously results in node *i+1* not being removed.")

A simple example of why mutual exclusion is important in practice can be visualized using a *singly linked list* of four items, where the second and third are to be removed. The removal of a node that sits between 2 other nodes is preformed by changing the `next` pointer of the previous node to point to the next node (in other words, if node *i* is being removed, then the `next` pointer of node *i-1* is changed to point to node *i+1*, thereby removing from the linked list any reference to node *i*). When such a linked list is being shared between multiple threads of execution, two threads of execution may attempt to remove two different nodes simultaneously, one thread of execution changing the next pointer of node *i-1* to point to node *i+1*, while another thread of execution changes the `next` pointer of node *i* to point to node *i+2*. Although both removal operations complete successfully, the desired state of the linked list is not achieved: node *i+1* remains in the list, because the `next` pointer of node *i-1* points to node *i+1*.

This problem, which is called a **race condition**, can be avoided by using the requirements of **mutual exclusion** to ensure that simultaneous updates to the same part of the list *can not occur*.

<a name="of5"></a>
## Topic 5 - Synchronization

In *computer science*, **synchronization** refers to one of two distinct but related concepts: **synchronization of processes**, and **synchronization of data**.
> **Process synchronization** refers to the idea that multiple processes are to join up or *handshake* at a certain point, in order to reach an agreement or commit to a certain sequence of action.

> **Data synchronization** refers to the idea of keeping multiple copies of a dataset in coherence with one another, or to maintain data integrety.
**Process synchronization** primitives are commonly used to implement **data synchronization**.

### Thread or process synchronization
**Thread synchronization** is defined as a mechanism which ensures that two or more concurrent processes or threads do not simultaneously execute some particular program segment known as *critical section*(TODO REF CONCURRENT). Processes' access to *critical section* is controlled by using synchronization techniques. When one thread start executing the *critical section* (serialized segment of the program) the other thread should wait until the first thread finishes. If proper synchronization techniques are not applied, it may cause a *race condition*(REF TODO) where the values of variables may be unpredictable and vary depending on the timings of *context switches* of the processes or threads.

For example, suppose that there are three processes, namely 1,2, and 3. All three of them are concurrently executing, and they need to share a common resource(critical section) as shown in Figure 1: ![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/Multiple_Processes_Accessing_the_shared_resource.png "Figure 1: Three processes accessing a shared rescource (critical section) simulataneously.")

Synchronization should be used here to avoid any conflicts for accessing this shared resource. Hence, when Process 1 and 2 both try to access that resource, it should be assigned to only one process at a time. If it is assigned to Process 1, the other process (Process 2) needs to wait until Process 1 frees that resource, as shown in Figure 2: 
![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/Shared_Resource_access_in_synchronization_environment.png "Figure 2: A process accessing a shared resource if available, based on some synchronization technique.").

Another **synchronization** requirement which needs to be considered is the order in which particular process or threads should be executed. For example, we cannot board a plane until we buy a ticket. Similarly, we cannot check e-mails without validating our credentials. In the same way, an ATM will not provide any service until the correct PIN has been entered. 

Other than mutual exclusion, synchronization also deals with the following:
- **Deadlocks**, which occurs when many processes are waiting for a shared resource (critical section) which is being held by some other process. In this case, the processes just keep waiting and execute no further.
- **Starvation**, which occurs when a process is waiting to enter the critical section, but other processes monopolize the critical section, and the first process is forced to wait indefinitely.
- **Priority inversion**, which occurs when a high-priority process is in the critical section, and it is interrupted by a medium-priority process. This violation of priority rules can happen under certain circumstances and may lead to serious consequences in **real-time systems**.
- **Busy waiting**, which occurs when a process frequently polls to determine if it has access to a critical section. This frequent polling robs processing time from other processes.


### Semaphores
**Semaphores** are signalling mechanisms which can allow one or more processes/threads to access a section. A **semaphore** has a flag which has a certain fixed value associated with it and each time a thread wishes to access the section, it decrements the flag. Similarly, when the thread leaves the section, the flag is incremented. If the flag is zero, the thread cannot access the section and gets blocked if it chooses to wait.

Some **semaphores** would allow only one thread or process in the code section. Such **semaphores** are called **binary semaphore** and are very similar to **mutex**(todo referanse). I.e. if the value of **semaphore** is 1, the thread is allowed to access and if the value is 0, the access is denied.

### Notes based on answers for exam questions

Pseudocode for task *3-1 - Exam 2017*
```
Semaphore mutex(1), Lefts(0), Rights(0);
int activeThreads = 0;
int waitingLefts = 0;
int waitingRights = 0;

void Left(){
    wait(mutex);
    if activeThreads == 0 && waitingRights > 0 do
        activeThreads += 2;
        signal(Right);
        signal(Left);
    end

    waitingLefts++;
    signal(mutex);

    wait(Left);

    wait(mutex);
    waitingLefts--;
    signal(mutex);
}

void Finished(){
    wait(mutex);
    activeThreads--;

    if activeThreads == 0 && waitingLefts > 0 && waitingRights > 0 do
        activeThreads += 2;
        signal(Right);
        signal(Left);
    end

    signal(mutex);
}
```
Pseudocode for task *3-2 - Exam 2017*
```
int activeThreads = 0;
int waitingLefts = 0;
int waitingRights = 0;

synchronized void Left(){
    while(activeThreads > 0 && waitingRights > 0){
        waitingLefts++;
        wait();
        waitingLefts--;
    }
    activeThreads++;
}
```

Pseudocode for task *4-1 - Exam 2016*

```
# The dining savages problem

int servings = 0;
mutex = Semaphore(1);
emptyPot = Semaphore(0);
fullPot = Semaphore(0);

# The one cook runs this code:
while True {
    emptyPot.wait();
    putServingsInPot(M);
    fullPot.signal();
}

# Any number of savages run the following code:
while True {
    mutex.wait();
        if servings == 0 {
            emptyPot.signal();
            fullPot.wait()
            servings = M;
        }
        servings--;
        getServingFromPot();
    mutex.signal();

    eat();
}
```

Pseudocode for task *4-2 - Exam 2016* - **Java**

```Java
class Pot {
    private unsigned int servings = 3;
    private bool awakenCook = false;

    synchronized void eat () {
        if (servings > 0) {
            servings--;
        }
        else {
            awakenCook = true;
            notifyAll();
            while (awakenCook) {
                wait();
            }
            servings--;
        }
    }

    synchronized void cook() {
        while (!awakenCook) {
            wait();
        }
        servings = 3;
        awakenCook = False();
        notifyAll();
    }
}
```

Pseudocode for task *4-3 - Exam 2016* - **Ada**

```Ada
Protected Object Pot:
    private unsigned int servings = 3;
    entry eat when servings > 0:
        servings = servings - 1;
    
    entry cook when servings == 0:
        servings = 3;
```

A big problem with deadlock analysis is scalability, as deadlock analysis is a global analysis, and in principle every new semaphore in the system multiplies the number of states to check by 2.

The **rand function** function does not work well with threads as it usually delivers the same number(often within a short time interval) or repeats sequences of 'random' numbers.

Readers/writers locks are motivated by a lot of readers which overlap in execution, starving any writers.


<a name="of6"></a>
## Topic 6 - Race conditions

A **race condition** is the behavior of an electronics, software, or other system where the system's substantive behavior is dependent on the sequence or timing of other uncontrollable events. It becomes a bug when one or more of the possible behaviors is undesirable. **Race conditions** can occur especially in logic circuits, multithreaded or distributed software programs.

**Race conditions** arise in software when an application depends on the sequence or timing of processes or threads to operate properly. As with electronics, there are **critical race conditions** that result in invalid execution and bugs. Critical race conditions often happen when the processes or threads depends on some shared state. Operations upon shared states are *critical sections* that must be mutually exclusive. Failure to obey this rule opens up the possibility of corrupting the shared state.

**Race conditions** have a reputation of being *difficult* to reproduce and debug, since the end result is *nondeterministic* and depends on the relative timing between interfering threads. Problems occuring in production systems can therefore disappear when running in debug mode, when additional logging is added, or when attaching a debugger, often referred to as a "Heisenbug". It is therefore better to avoid **race conditions** by careful software design rather than attempting to fix them afterwards.

### Example

As a simple example, let us assume that two threads want to increment the value of a global integer value by one. Ideally the following sequence of operations would take place:

| Thread 1      | Thread 2      |    |Integer value  |
|:-------------:|:-------------:|:--:|:--------------:|
|   |  |  |     0        |
| read value | | <- | 0 |
| *increase value* | | | 0 |
| write back | | -> | 1 |
| | read value | <- | 1 |
| | *increase value* | | 1 |
| | write back | -> | 2 |

In the case shown above, the final value is 2, as expected. However, if the two threads run simultaneously without locking or synchronization, the outcome of the operation could be wrong. The alternative sequence of operations below demonstrates this scenario:

| Thread 1      | Thread 2      |    |Integer value  |
|:-------------:|:-------------:|:--:|:--------------:|
|   |  |  |     0        |
| read value | | <- | 0 |
| | read value | <- | 0 |
| *increase value* | | | 0 |
| | *increase value* | | 0 |
| write back | | -> | 1 |
| | write back | -> | 1 |

In this case, the final value is 1 instead of the expected result of 2. This occurs because here the increment operations are not *mutually exclusive*. *Mutually exclusive* operations are those that cannot be interrupted while accessing some resource such as memory location.

<a name="of7"></a>
## Topic 7 - Inheritance Anomaly

The **Inheritance Anomaly** is a failure of inheritance to be a useful mechanism for code-reuse that is caused by the addition of synchronization constructs (method guards, locks, etc) to object-oriented programming. When deriving a subclass through inheritance, the presence of synchronization code often forces method overriding on a scale much larger than when synchronization constructs are absent, to the point where there is no practical benefit to using iheritance at all.

The essence of the anomaly, from a **programmers perspective**, is as follows:
>I have a class *C* which implements some behaviour *B*. I have defined a subtype of behavior *B*, say *B**, and now I must create a new class *C** that implements *B**. *C** should be able to inherit from *C* to reuse the code in C. However, I am forced to redifine much of C's behaviour in writing in *C**. This re-writing is **the anomaly**, as it occurs far more often when concurrency is involved than when it is not.



<a name="of8"></a>
## Topic 8 - Priority ceiling protocol

In **real-time computing**, the **priority ceiling protocol** is a synchronization protocol for *shared resources* to avoid unbounded **priority inversion** and mutual **deadlock** due to wrong nesting of critical sections. In this protocol each resource is assigned a **priority ceiling**, which is a priority equal to the highest priority of *any task* which may lock the resource. The protocol works by *temporarily raising* the priorities of tasks in certain situations, thus it requires a **scheduler** that supports **dynamic priority scheduling**.


<a name="of9"></a>
## Topic 9 - Scheduling

In **computing**, **scheduling** is the method by which work is assigned to resources that complete the work. The work may be virtual computation elements such as *threads*, *processes* or *data flows*, which are in turn scheduled onto hardware resources such as processors, network links, or expansion cards.

A **scheduler** is what carries out the **scheduling** activity. **Schedulers** are often implemented so they keep all computer resources busy (as in load balancing), allow multiple users to share system resources effectively, or to achieve a target quality of service. **Scheduling** is fundamental to computation itself, and an intrisic part of the *execution model* of a computer system; the concept of **scheduling** makes it possible to have computer **multitasking** with a single CPU. 

### Scheduling disciplines

**Scheduling disciplines** are algorithms used for distributing resources amoong parties which simultaneously and asynchronously request them.

The main purposes of **scheduling algorithms** are to minimize *resource starvation* and to *ensure fairness* among the parties utilizing the resources. **Scheduling** deals with the problem of deciding which of the outstading requests is to be allocated resources. There are many different **scheduling algorithms**. Below, we introduce several of them.

- **First come, first served**
    - *First in, first out* (FIFO), also known as *first come, first served* (FCFS), is the simplest scheduling algorithm. **FIFO** simply queues processes in the order that they arrive in the ready queue. This is commonly used for a **task queue**, as illustrated below.

![alt text](https://github.com/Pathorse/TTK4145-Real-Time-Programming/blob/master/Images/1024px-Thread_pool.svg.png "A sample thread pool (green boxes) with a queue (FIFO) of waiting tasks (blue) and a queue of completed tasks (yellow)")

- **Priority scheduling**
    - Earliest deadline first (EDF) or *least time* to go is a **dynamic scheduling algorithm** used in **real-time operating systems** to place processes in a priority queue. Whenever a scheduling event occurs (a task finishes, new task is released, etc.), the queue will be searched for the process closest to its deadline, which will be the next to be scheduled for execution.

- **Shortest remaining time first**
    - Similar to *shortest job first* (SFJ). With this strategy the scheduler arranges processes with the least estimated processing time remaining to be next in the queue. This *requires advanced knowledge* or *estimations* about the time required for a process to complete.

- **Fixed priority pre-emptive scheduling**
    - The operating system assigns a fixed priority rank to every process, and the **scheduler** arranges the processes in the ready queue in order of their priority. Lower-priority processes get interrupted by incoming higher-priority processes.

- **Round-robin scheduling**
    - The **scheduler** assigns a fixed time unit per process, and cycles through them. If process completes within that time-slice it gets terminated otherwise it is rescheduled after giving a chance to all other processes.

- **Multilevel queue scheduling**
    - This is used for situations which processes are easily divided into different groups. For example, a common division is made between foreground (interactive) processes and background (batch) processes. These two types of processes have different response time requirements and so may have different **scheduling** needs. It is *very useful* for shared memory problems.

- **Work-conserving schedulers**
    - A **work-conserving scheduler** is a scheduler that always tries to keep the scheduled resources busy, if there are submitted jobs ready to be scheduled.

<a name="of10"></a>
## Topic 10 - Spesific language features

### C - setjmp.h
**setjmp.h is a header defined in the C standard library to provide "non-local jumps": 
>Control flow that deviates from the usual subroutine call and return sequence.

The complementary functions `setjmp` and `longjmp` provide this functionality. 

A typical use of `setjmp`/`longjmp` is implementation of an exception mechanism that exploits the ability of `longjmp` to reestablish program or thread state, even across multiple levels of function calls. A less common use of `setjmp` is to create syntax similar to coroutines.

`setjmp` saves the current environment (the program state), at some point of program execution, into a platform-specific data structure, `jmp_buf`, that can be used at some later point of prorgam execution by `longjmp` to restore the program state to that saved by `jmp_buf`. This process can be imagined to be a "jump" back to the point of program execution where `setjmp` saved the environment.

### POSIX Threads - pthreads

**POSIX Threads**, usually referred to as **pthreads**, is an execution model that exists independently form a language, as well as a parallel execution model. It allows a program to control multiple different flows of work that overlap in time. Each flow work is referred to as a thread, and creation and control over these flows is achieved by making calls to the POSIX Threads API. 

**pthreads** defines a set of **C** programming language types, functions and constants. It is implemented with a `pthread.h` header and a thread library.

There are around 100 threads procedures, all prefixed `pthread_` and they can be categorized into four groups:
- *Thread management* - creating, joining threads etc..
- *Mutexes*
- *Condition variables*
- *Synchronization* between threads using read/write locks and barriers

`pthread_cancel()`
>The **pthread_cancel()** function sends a cancellation request to the thread *thread*. Whether and when the target thread reacts to the cancellation request depends on two attributes that are under the control of that thread: its cancellability *state* and *type*.

When a cancellation requested is acted on, the following steps occur for *thread* (in this order):

1. Cancellation clean-up handlers are popped (in the reverse of the order in which they were pushed) and called.
2. Thread-specific data destructors are called, in an unspecified order.
3. The thread is terminated.

The above steps happens **asynchronously** with respect to the `pthread_cancel()` call; the return status of `pthread_cancel()` merely informs the caller whether the cancellation request was successfully queued.

### Ada

#### Guards

**Adas guards** may only test on the protected object's variables to know when to re-evaluate the guards and wake up sleeping processes.

The **guards** are used to guard the entry points of the `select` statement to prevent the kinds of silly things that can happen. A **guard** is simply a *BOOLEAN* condition that must be satisfied before that particular entry point can be accepted and its logic executed. The general form of the `select` statement with **guards** is given as:

```Ada
select
    when <BOOLEAN condition> =>
        accept ...;     -- Complete entry point logic
or
    when <BOOLEAN condition> =>
        accept ...;     -- Complete entry point logic
or
    when <BOOLEAN condition> =>
        accept ...;     -- Complete entry point logic
end select;
```

and there is no limit to the number of permissible selections, each being seperated by the reserved word `or`. In fact, one or more of the selections can have **no guard**, in which case it is similar to having a **guard** which always evaluates to *TRUE*. When the `select` statement is encountered, each of the **guards** is evaluated for *TRUE* or *FALSE*, and those conditions that evaluate to *TRUE* are allowed to enter into the active wait state for an entry, while those that have **guards** evaluating to *FALSE* are not. Those with **guards** evaluating to *FALSE* are treated as if they didn't exist for this pass through the loop. Once the **guards** are evaluated upon entering the `select` statement, they are not reevaluated until the next time the `select` statement is encountered, but remain static.

#### Asynchronous transfer of control

An **Ada asynchronous transfer of control** `select_statement` provides asynchronous transfer of control upon completion of an entry call or the expiration of a delay. The syntax is detailed below:

```Ada
select
    triggering_alternative
then abort
    abortable_part
end select;
```

Examples:

```Ada
loop
    select
        Terminal.Wait_For_Interrupt;
        Put_Line("Interrupted");
    then abort
        -- This will be abandoned upon terminal interrupt
        Put_Line("-> ");
        Get_Line(Command, Last);
        Process_Command(Command(1..Last));
    end select;
end loop;
```

```Ada
select
    delay 5.0;
    Put_Line("Calculation does not converge");
then abort
    -- This calculation should finish in 5.0 seconds
    -- if not, it is assumed to diverge
    Horribly_complicated_Recursive_Function(X,Y);
end select;
```


### Java - AsynchronouslyInterruptedException

The **AsynchronouslyInterruptedException** is a special exception that is thrown in response to an attempt to asynchronously transfer the locus of control of a schedulable object.

A schedulable object that is executing a method or constructor, which is declared with an **AsynchronouslyInterruptedException** in its `throws` clause, can be asynchronously interrupted except when it is executing in the lexical scope of a synchronized statement within that method/constructor. As soon as the schedulable object leaves the lexical scope of the method by calling another method/constructor it may be asynchronously interrupted if the called method/constructor is asynchronously interruptible.

Written by Paal Arthur Schjelderup Thorseth


### TODO
- concurrency
    - mutual exclusion
    - race conditions
    - optimistic concurrency control
        - we assume that interleaving threads under preemptive scheduling does no damage; then use fault tolerance to handle it when it happens anyways.
    - Error recovery
        - Backwards
        - Forwards
    - Atomic actions
    - Process pairs
- redundancy
- Transition diagrams