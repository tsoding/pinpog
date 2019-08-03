# PinPog

Our goal is to write a game that fits into 512 bytes bootloader and
works in 16 bit real mode on any IBM PC compatible machine without any
Operating System.

- Development is done on https://twitch.tv/tsoding
- Archive of the streams: https://www.twitch.tv/collections/VAcjkyTlqRVXuA

## Run the game in QEMU

Install [qemu](https://www.qemu.org/) first.

```console
$ qemu-system-i386 -soundhw pcspk pinpog
```

## Making Bootable USB stick on Linux

**WARNING! THE AUTHORS OF THE GAME ARE NOT RESPONSIBLE FOR ANY DAMAGED
HARDWARE. SEE LICENSE FOR MORE INFORMATION.**

1. Get a USB stick (at least 512 bytes Kappa)
1. Plug it in
1. Find the block device of the USB drive using something like
   [lsblk](https://linux.die.net/man/8/lsblk)
1. Use [dd](https://linux.die.net/man/1/dd) to write the image to the
   USB drive: `sudo dd if=./pinpog of=/dev/<usb-drive>`

## Controls

- `a`, `d` - move racket sideways,
- `f` - restart the game,
- `space` - toggle pause.

## Support

You can support my work via

- Twitch channel: https://www.twitch.tv/subs/tsoding
- Patreon: https://www.patreon.com/tsoding
