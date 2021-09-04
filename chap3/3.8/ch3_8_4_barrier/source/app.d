import core.sync.barrier;
import core.thread;
import std.stdio;

void main()
{
    Thread[] arr = [];

    auto barrier = new Barrier(10);

    foreach (_; 0 .. 10)
    {
        auto th = new Thread(() {
                barrier.wait;
                writeln("finished barrier");
            }).start;
        arr ~= th;
    }

    foreach (th; arr)
    {
        th.join;
    }
}
