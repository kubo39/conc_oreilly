import core.sync.mutex;
import std.stdio;

void main()
{
    int data = 0;
    auto lock0 = new Mutex;
    auto lock1 = lock0;

    synchronized(lock0)
    {
        synchronized(lock1)
        {
            writeln(lock0);
            writeln(lock1);
        }
    }
}
