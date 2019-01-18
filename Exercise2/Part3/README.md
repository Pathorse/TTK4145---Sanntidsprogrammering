# Protection against data races

This is an optional exercise. You are not recommended to do this for "completion" or "achievement points". You should only do it if you're interested in learning more about how different languages can protect against data races, or you're considering to use one of the featured languages in your project. The languages chosen is not a complete list, but rather some examples that might be useful in context to this course.

## Erlang
Erlang disallows mutability of variables completely, a new state will instead be reached by calling into a different function (or the same function with different arguments). This means it will be impossible to solve the task from Part2 with lock based synchronization. Instead the "go-channel" approach needs to be taken, and a server needs to be created. These servers are so common in Erlang that they have been made an [OTP design pattern](http://erlang.org/doc/design_principles/gen_server_concepts.html). To not obscurify the erlang code this approach have not been taken in the starter code, instead a program very similar to the go-channel solution have been made. Complete the program and verify that the answer is 0.

![alt text](/img/cant_get_data_races.jpg "Erlang disallows mutation of variables")

## Rust
Rust uses it's static type system to make sure that no data races is possible. This is possible by using the [marker traits](https://doc.rust-lang.org/std/marker/) [`Send` and `sync`](https://doc.rust-lang.org/beta/nomicon/send-and-sync.html). A data type is `Send` if you're allowed to send the data to another thread. If a data type is not marked as `Send` it's statically guaranteed that it will never be sent between threads. A data type is `Sync` if it's safe to share between threads (safe to access concurrently).

The primitive integer types in rust are not "thread safe" and thus not `Sync`, but there is no reason they can't be sent between threads so `Send` is implemented. Since Rust doesn't take a stance in which concurrency model to use (as long as you avoid undefined behaviour) both the "channel" and "lock" solution is possible. A [`Mutex`](https://doc.rust-lang.org/std/sync/struct.Mutex.html) takes something that is `Send` and make it `Sync` while [`mpsc`](https://doc.rust-lang.org/std/sync/mpsc/index.html) allows you to create "channels" for data types that implement `Send`.

The lock based approach has been taken in the starter code, you are of course free to re-write it into the `mpsc` approach if you feel like it.
