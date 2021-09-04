import core.sync.mutex : Mutex;
import core.thread : Thread;
import std.stdio;

void some_func(Mutex lock, ref ulong val)
{
    while (true)
    {
        synchronized (lock)
        {
            ++val;
            writefln("%d", val);
        }
    }
}

void main()
{
    auto lock = new Mutex;
    auto val = 0UL;

    // スレッド生成
    auto th0 = new Thread(() => some_func(lock, val)).start;
    auto th1 = new Thread(() => some_func(lock, val)).start;

    // 待ち合わせ
    th0.join;
    th1.join;
}
