# Python 3.3.3 and 2.7.6
# python fo.py

import threading


# Potentially useful thing:
#   In Python you "import" a global variable, instead of "export"ing it when you declare it
#   (This is probably an effort to make you feel bad about typing the word "global")
i = 0
i_Lock = threading.Lock()

def incrementingFunction():
    global i
    global i_Lock
    # TODO: increment i 1_000_000 times
<<<<<<< HEAD
    # Added new code here ----------------------------
    for x in range(1000000):
        i = i + 1
    #-------------------------------------------------

def decrementingFunction():
    global i
    # TODO: decrement i 1_000_000 times
    # Added new code here ----------------------------
    for x in range(1000000):
        i = i - 1
    # -------------------------------------------------


=======
    i_Lock.acquire()
    for j in range(0,1000000):
        i = i + 1
    i_Lock.release()

def decrementingFunction():
    global i
    global i_Lock
    # TODO: increment i 1_000_000 times
    i_Lock.acquire()
    for j in range(0,1000001):
        i = i - 1
    i_Lock.release()
>>>>>>> Håvard

def main():
    # TODO: Something is missing here (needed to print i)
    global i

    incrementing = threading.Thread(target = incrementingFunction, args = (),)
    decrementing = threading.Thread(target = decrementingFunction, args = (),)
    
    # TODO: Start both threads
<<<<<<< HEAD

    incrementing.start()
    decrementing.start()
    
=======
    incrementing.start()
    decrementing.start()

>>>>>>> Håvard
    incrementing.join()
    decrementing.join()
    
    print("The magic number is %d" % (i))


main()
