
#ifndef _HAKA_THREAD_H
#define _HAKA_THREAD_H

#include <stddef.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>

#include <haka/types.h>
#include <haka/compiler.h>


/* Thread functions */

int thread_get_packet_capture_cpu_count();
void thread_set_packet_capture_cpu_count(int count);
int thread_get_cpu_count();
int thread_get_id();
void thread_set_id(int id);


/* Atomic counter */

typedef volatile uint32 atomic_t;

INLINE uint32 atomic_inc(atomic_t *v)
{
	return __sync_add_and_fetch(v, 1);
}

INLINE uint32 atomic_dec(atomic_t *v)
{
	return __sync_sub_and_fetch(v, 1);
}

INLINE uint32 atomic_get(atomic_t *v)
{
	return *v;
}

INLINE void atomic_set(atomic_t *v, uint32 x)
{
	*v = x;
}


/* Mutex */

typedef pthread_mutex_t mutex_t;

#define MUTEX_INIT PTHREAD_MUTEX_INITIALIZER

bool mutex_init(mutex_t *mutex, bool recursive);
bool mutex_destroy(mutex_t *mutex);
bool mutex_lock(mutex_t *mutex);
bool mutex_trylock(mutex_t *mutex);
bool mutex_unlock(mutex_t *mutex);


/* Semaphore */

typedef sem_t semaphore_t;

bool semaphore_init(semaphore_t *semaphore, uint32 initial);
bool semaphore_destroy(semaphore_t *semaphore);
bool semaphore_wait(semaphore_t *semaphore);
bool semaphore_post(semaphore_t *semaphore);


/* Thread local storage */

typedef pthread_key_t local_storage_t;

bool local_storage_init(local_storage_t *key, void (*destructor)(void *));
bool local_storage_destroy(local_storage_t *key);
void *local_storage_get(local_storage_t *key);
bool local_storage_set(local_storage_t *key, const void *value);


#endif /* _HAKA_THREAD_H */
