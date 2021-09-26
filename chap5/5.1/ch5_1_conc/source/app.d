import core.sys.linux.epoll;
import std.exception;
import std.socket;
import std.stdio;

void main()
{
    auto listener = new TcpSocket;
    scope (exit) listener.close;
    auto address = new InternetAddress("127.0.0.1", 10000);
    listener.bind(address);
    listener.listen(1024);

    int epfd = epoll_create1(0);

    socket_t listenfd = listener.handle();
    {
        epoll_data_t data;
        data.fd = listenfd;
        auto ev = epoll_event(EPOLLIN, data);
        int ret = epoll_ctl(epfd, EPOLL_CTL_ADD, listenfd, &ev);
        errnoEnforce(ret == 0);
    }

    Socket[socket_t] fd2buf;
    epoll_event[1024] events;

    while (true)
    {
        auto nfds = epoll_wait(epfd, events.ptr, events.length, -1);
        errnoEnforce(nfds >= 0);

        foreach (n; 0 .. nfds)
        {
            if (listenfd == cast(socket_t) events[n].data.fd)
            {
                auto stream = listener.accept();
                socket_t fd = stream.handle();
                fd2buf[fd] = stream;

                writefln("accept: fd = %d", fd);

                epoll_data_t data;
                data.fd = fd;
                auto ev = epoll_event(EPOLLIN, data);
                epoll_ctl(epfd, EPOLL_CTL_ADD, fd, &ev);
            }
            else
            {
                auto fd = cast(socket_t) events[n].data.fd;
                auto stream = fd2buf[fd];

                ubyte[1024] buf;
                auto ret = stream.receive(buf);

                if (ret == 0)
                {
                    epoll_data_t data;
                    data.fd = fd;
                    auto ev = epoll_event(EPOLLIN, data);
                    epoll_ctl(epfd, EPOLL_CTL_DEL, fd, &ev);
                    fd2buf[fd].close;
                    fd2buf.remove(fd);
                    writefln("closed: fd = %d", fd);
                    continue;
                }

                buf = buf[0..n];
                writefln("read: fd = %d, buf = %s", fd, buf);

                stream.send(buf);
            }
        }
    }
}
