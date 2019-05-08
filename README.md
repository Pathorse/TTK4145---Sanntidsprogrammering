# TTK4145-Real-time Programming
<meta name ="author" content="Paal A. S. Thorseth">

**Below you find notes regarding important topics in Real-time Programming. The topics are based on relevant exams for TTK4145 at NTNU.**

## List of topics
1. [Topic 1 - *Fault tolerance*](#of1)
2. [Topic 2 - *Acceptance tests*](#of2)




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



<a name="of2"></a>
## Topic 2 - Acceptance tests

In engineering and its various subdisciplines **acceptance testing** is a test conducted to determine if the requirements of a specification or contract are met. 

In *software testing* the ISTQB(International Software Testing Qualifications Board) defines **acceptance testing** as:

>>Formal testing with respect to user needs, requirements, and business processes conducted to determine whether or not a system satisfies the acceptance criteria and to enable the user, customers or other authorized entity to determine whether or not to accept the system.


### Types of acceptance testing
- **User acceptancte testing - UAT**
    - This may include factory acceptance testing (FAT), i.e. the teseting done by a vendor before the product or system is moved to its destination site, after which site acceptance testing (SAT) may be preformed by the users at the site.
- **Operational acceptance testing - OAT**
    - Also known as operational readiness testing, this refers to the chechking done to a system to ensure that processes and procedures are in place to allow the system to be used and maintained. This may include checks done to back-up facilities, procedures for disaster recovery, training for end users, maintenance procedures, and security procedures. 
- **Contract and regulation acceptance testing**
    - In contract acceptance testing, a system is tested against acceptance criteria as documented in a contract, before the system is accepted. In regulation acceptance testing, a system is tested to ensure it meets governmental, legal and safety standards.






Written by Paal Arthur Schjelderup Thorseth