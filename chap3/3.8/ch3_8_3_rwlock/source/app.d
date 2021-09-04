import core.sync.rwmutex;
import std.stdio;

void main()
{
    auto lock = new ReadWriteMutex;
    auto val = 10;

    // うーん
    synchronized (lock.reader)
    {
        synchronized (lock.reader)
        {
            writeln("v1 = ", val);
            writeln("v2 = ", val);
        }
    }

    {
        auto v = lock.writer;
        synchronized (v)
        {
            val = 7;
            writeln("v = ", val);
        }
    }
}
