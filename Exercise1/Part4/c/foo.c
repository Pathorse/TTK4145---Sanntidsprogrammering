#include <pthread.h>
#include <stdio.h>

int i = 0;

// Note the return type: void*
void* incrementingThreadFunction(){
    // TODO: increment i 1_000_000 times

    // Added code below ---------------------------------
    int count;
    for (count = 0; count < 1000000;count++)
    {
        i = i + 1;
    }
    // --------------------------------------------------

    return NULL;
}

void* decrementingThreadFunction(){
    // TODO: decrement i 1_000_000 times

    // Added code below ---------------------------------
    int count;
    for (count = 0; count < 1000000;count++)
    {
        i = i - 1;
    }
    // --------------------------------------------------

    return NULL;
}


int main(){
    // TODO: declare incrementingThread and decrementingThread (hint: google pthread_create)
    
    // Added code below ---------------------------------
    pthread_t incrementingThread;
    pthread_t decrementingThread;
    // --------------------------------------------------
    

    pthread_create(&incrementingThread, NULL, incrementingThreadFunction, NULL);
    pthread_create(&decrementingThread, NULL, decrementingThreadFunction, NULL);
    
    pthread_join(incrementingThread, NULL);
    printf("The magic number is: %d\n", i);
    pthread_join(decrementingThread, NULL);
    
    printf("The magic number is: %d\n", i);
    return 0;
}
