#include <pthread.h>
#include <stdio.h>


int i = 0;
pthread_mutex_t lock;

// Note the return type: void*
void* incrementingThreadFunction(){
    // Lock resource
    pthread_mutex_lock(&lock);

    for (int j = 0; j < 1000000; j++) {
	// TODO: sync access to i
	i++;
    }

    // Unlcok resource
    pthread_mutex_unlock(&lock);

    return NULL;
}

void* decrementingThreadFunction(){
    // Lock resource
    pthread_mutex_lock(&lock);

    for (int j = 0; j < 1000001; j++) {
	// TODO: sync access to i
	i--;
    }

    // Unlock resource
    pthread_mutex_unlock(&lock);

    return NULL;
}


int main(){


    if (pthread_mutex_init(&lock, NULL) != 0)
    {
        printf("\n mutex init failed");
        return 1;
    }

    pthread_t incrementingThread, decrementingThread;
    
    pthread_create(&incrementingThread, NULL, incrementingThreadFunction, NULL);
    pthread_create(&decrementingThread, NULL, decrementingThreadFunction, NULL);
    
    pthread_join(incrementingThread, NULL);
    pthread_join(decrementingThread, NULL);
    
    printf("The magic number is: %d\n", i);


    // destroy mutex
    pthread_mutex_destroy(&lock);
    return 0;
}
