import core.thread;
import std.stdio;
import std.typecons;

import channel : channel;

enum NUM_LOOP = 100;
enum NUM_THREADS = 4;

void main()
{
    auto pair = channel!(Tuple!(int, int))(4);
    auto tx = pair[0];
    auto rx = pair[1];
    Thread[] arr;

    {
        auto t = new Thread({
            auto cnt = 0;
            while (cnt < NUM_THREADS * NUM_LOOP)
            {
                auto n = rx.recv();
                writefln("recv: n = %s", n);
                cnt++;
            }
        }).start;
        arr ~= t;
    }

    foreach (i; 0 .. NUM_THREADS)
    {
        auto t = new Thread({
                foreach (j; 0 .. NUM_LOOP)
                {
                    tx.send(tuple(i, j));
                }
            }).start;
        arr ~= t;
    }

    foreach (t; arr)
    {
        t.join;
    }
}
