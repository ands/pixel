# Pixelflut
Fast pixelflut server written in C. It is a collaborative coding game. See https://cccgoe.de/wiki/Pixelflut for details about the game itself. In short: project the pixelflut server output onto a wall where many people can see it. Connected clients can then set single pixels by sending a string like "PX [x] [y] [color]\n" (e.g. "PX 100 300 00FF42\n") to its TCP socket. Use netcat, python or whatever you want.

## Hardware requirements
Every cpu with a little bit of power (for 2D SDL) should work. On an Core i3-4010U you can easily utilize a 1 GBit Nic. On Raspberry Pi 4B you get around 30 megabytes/sek. On large events, 10 GBit fiber and a few more CPU-Cores are even more fun. On real server hardware you want to add a graphics card. One thread per CPU-Core seems to be a good rule of thumb.

## Features
- Multithreaded
- Can display an overlay with some statistics
- Webinterface serves real-time WebGL histogram and help text (same TCP port)
- Optional fade to black for old pixels to encourage pixel refreshes
- Take manual and periodic screenshots
- Supported commands:
  - send pixel: 'PX {x} {y} {GG or RRGGBB or RRGGBBAA as HEX}\n'
  - set offset for future pixels: 'OFFSET {x} {y}\n'
  - request pixel color: 'PX {x} {y}\n'
  - request output resolution: 'SIZE\n'
  - request client connection count: 'CONNECTIONS\n'
  - request help message with all commands: 'HELP\n'

## Build
On a clean Debian installation with the "SSH server" and "standard system utilities" selected during setup. A system with desktop shound also work.
```
apt update
apt install xorg git build-essential pkg-config libsdl2-dev -libpng-dev -y
git clone https://github.com/larsmm/pixelflut.git
cd pixelflut
make
```

## Keys
- q or ctrl+c: quit
- f: toggle fullscreen
- s: take screenshot (png file in pixelflut dir)

## Options
```
./pixelflut --help
```
```
usage: ./pixelflut [OPTION]...
options:
        --width <pixels>                Framebuffer width. Default: Screen width.
        --height <pixels>               Framebuffer width. Default: Screen height.
        --port <port>                   TCP port. Default: 1234.
        --connection_timeout <seconds>  Connection timeout on idle. Default: 5s.
        --connections_max <n>           Maximum number of open connections. [1-60000] Default: 1000.
        --threads <n>                   Number of connection handler threads. Default: 4.
        --no-histogram                  Disable calculating and serving the histogram over HTTP.
        --window                        Start in window mode.
        --fade_out                      Enable fading out the framebuffer contents.
        --fade_interval <frames>        Interval for fading out the framebuffer as number of displayed frames. Default: 4.
        --hide_text                     Hide the overlay text.
        --show_ip_instead_of_hostname   Show IPv4 of interface with default-gateway on overlay.
        --show_custom_ip <IP>           Show specific IP instead of hostname.
        --screenshot_interval <seconds> Time between screenshots. (png files in pixelflut dir) Default: disabled.
        --screenshot_use_bmp            Use bmp instead of png because of speed.
```

## Start Server locally
If you are using linux without a desktop environment, start x server first:
```
startx &  # start in background
```
Start pixelflut server:
```
./pixelflut
```

## Start Server over ssh
If you are using linux with a desktop environment it has to run on the same user as you are using to connect over ssh. List availible displays:
```
ps e | grep -Po " DISPLAY=[\.0-9A-Za-z:]* " | sort -u
```
Start pixelflut on local display (x forwarding), e.g.:
```
DISPLAY=localhost:10.0 ./pixelflut --window
```
Start pixelflut on server display, e.g.:
```
DISPLAY=:0.0 ./pixelflut
```

## Connection limit
Best practise: set overall limit of the pixelflut-server high (--connections_max 1000) and limit max connections to the pixelflut port (default: 1234) per IP via iptables to 10-20:
```
nano iptables.save
```
paste (set limit in --connlimit-above):
```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -p tcp -m tcp --dport 1234 --tcp-flags FIN,SYN,RST,ACK SYN -m connlimit --connlimit-above 20 --connlimit-mask 32 --connlimit-saddr -j REJECT
COMMIT
```
Ctrl+x, y, return to save.
Activate:
```
iptables-restore < iptables.save
```

## Display driver
Sometimes the free NVidia driver has problems on multiple displays. So install the proprietary driver:
1. detect the chip and find the right driver:
```
nano /etc/sources/sources.list
```
Add: "contrib non-free" after each source
```
apt install nvidia-detect
nvidia-detect
```
2. install driver:
```
apt install for example: nvidia-legacy-340xx-driver
reboot
```
3. configure your displays:
```
startx
```
run the following inside the x-session and setup your displays:
```
nvidia-settings
```
or via SSH:
```
DISPLAY=:0 nvidia-settings
```
maybe restart x server

## Prevent standby
If you are using a notebook and want to close the lit. To disable all standby stuff:
```
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

## TODO
- Use epoll() to check multiple sockets for I/O events at once
- better network-statistics
- ipv6