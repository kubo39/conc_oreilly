import core.atomic;
import core.thread;
import std.stdio;

enum NUM_THREADS = 4;
enum NUM_LOOP = 1000;

shared struct SpinLock(T)
{
    bool locked;
    T data;

    this(T v)
    {
        this.locked = false;
        this.data = v;
    }

    void lock()
    {
        while (true)
        {
            while (this.locked.atomicLoad!(MemoryOrder.raw)) {}

            // ロック間共有変数をアトミックに書き込み
            if (casWeak!(MemoryOrder.acq, MemoryOrder.raw)
                (&this.locked, false, true))
            {
                break;
            }
        }
    }

    void unlock()
    {
        atomicStore!(MemoryOrder.rel)(this.locked, false);
    }
}

void main()
{
    auto spin = new shared SpinLock!int(0);
    Thread[] arr = [];

    foreach (_; 0 .. NUM_THREADS)
    {
        auto t = new Thread({
                foreach (_; 0 .. NUM_LOOP)
                {
                    spin.lock();
                    scope(exit) spin.unlock();
                    spin.data.atomicOp!"+="(1);
                }
            }).start;
        arr ~= t;
    }

    foreach (t; arr)
    {
        t.join;
    }

    writefln("COUNT = %d (expected = %d)",
             spin.data,
             NUM_THREADS * NUM_LOOP);
}
