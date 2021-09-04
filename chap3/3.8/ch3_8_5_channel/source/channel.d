module channel;

import core.sync.condition;
import core.sync.mutex;
import core.sync.semaphore;
import std.container;
import std.typecons;

struct Sender(T)
{
    Semaphore sem;
    Mutex m;
    DList!T* buf;
    Condition cond;

    void send(T data)
    {
        this.sem.wait;
        synchronized(this.m)
        {
            this.buf.insert(data);
            this.cond.notify;
        }
    }
}

struct Receiver(T)
{
    Semaphore sem;
    Mutex m;
    DList!T* buf;
    Condition cond;

    T recv()
    {
        synchronized(this.m)
        {
            while (true)
            {
                if (this.buf.empty)
                {
                    this.cond.wait;
                }
                else
                {
                    T data = this.buf.front;
                    this.buf.removeFront;
                    this.sem.notify;
                    return data;
                }
            }
        }
    }
}

Tuple!(Sender!T, Receiver!T) channel(T)(uint max)
{
    assert(max > 0);
    auto sem = new Semaphore(max);
    auto m = new Mutex;
    auto buf = new DList!T;
    auto cond = new Condition(m);

    auto sender = Sender!T(sem, m, buf, cond);
    auto receiver = Receiver!T(sem, m, buf, cond);
    return tuple(sender, receiver);
}
