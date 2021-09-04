import core.sync.mutex;
import core.sync.condition;
import core.thread;
import std.stdio;

__gshared Mutex lock;
__gshared Condition cvar;

void child(ulong id, ref bool started)
{
    synchronized (lock)
    {
        while (!started)
        {
            cvar.wait;
        }
        writeln("child");
    }
}

void parent(ref bool started)
{
    synchronized (lock)
    {
        started = true;  // 共有変数を更新
        cvar.notifyAll;
        writeln("parent");
    }
}

void main()
{
    lock = new Mutex;
    cvar = new Condition(lock);

    bool started = false;

    auto c0 = new Thread(() => child(0, started)).start;
    auto c1 = new Thread(() => child(1, started)).start;
    auto p = new Thread(() => parent(started)).start;

    thread_joinAll;
}
