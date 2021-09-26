import core.thread.fiber;
import std.stdio;

enum HelloState
{
    Hello,
    World,
    End,
}

void main()
{
    auto hello = new Fiber({
            with(HelloState)
            {
                auto state = Hello;
                while (state != End)
                {
                    final switch (state)
                    {
                    case Hello:
                        writeln("Hello, ");
                        state = World;
                        break;
                    case World:
                        writeln("World!");
                        state = End;
                        break;
                    case End:
                        break;
                    }
                    Fiber.yield;
                }

            }
        });

    hello.call;
    hello.call;
    hello.call;
    assert(hello.state == Fiber.State.TERM);
    // hello.call;  // --> segv!
}
