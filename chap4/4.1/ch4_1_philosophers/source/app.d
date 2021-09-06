import core.sync.mutex;
import core.thread;
import std.stdio;

void main()
{
    auto c0 = new shared Mutex;
    auto c1 = new shared Mutex;

    auto p0 = new Thread({
            foreach (_; 0 .. 100)
            {
                synchronized (c0)
                {
                    synchronized (c1)
                    {
                        writeln("0: eating");
                    }
                }
            }
        }).start;

    auto p1 = new Thread({
            foreach (_; 0 .. 100)
            {
                synchronized (c1)
                {
                    synchronized (c0)
                    {
                        writeln("1: eating");
                    }
                }
            }
        }).start;

    p0.join;
    p1.join;
}
