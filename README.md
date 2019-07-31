[![Build Status](https://travis-ci.org/tsoding/pinpog.svg?branch=master)](https://travis-ci.org/tsoding/pinpog)

# PinPog

Our goal is to write a game that fits into 512 bytes bootloader and
works in 16 bit real mode on any IBM PC compatible machine without any
Operating System.

- Development is done on https://twitch.tv/tsoding
- Archive of the streams: https://www.twitch.tv/collections/VAcjkyTlqRVXuA

![](https://i.imgur.com/AKEjIKw.gif)

## Dependencies

First install these programs:

- [nasm]
- [qemu]

## Quick Start

### Build the game

```console
$ nasm pinpog.asm -o pinpog
```

### Run the game in QEMU

```console
$ qemu-system-i386 pinpog
```

## Making Bootable USB stick

**WARNING! THE AUTHORS OF THE GAME ARE NOT RESPONSIBLE FOR ANY DAMAGED HARDWARE. SEE LICENSE FOR MORE INFORMATION.**

### Linux

1. Build the image of the game: `$ make pinpog`
1. Get a USB stick (at least 512 bytes Kappa)
1. Plug it in
1. Find the block device of the USB drive using something like [lsblk](https://linux.die.net/man/8/lsblk)
1. Use [dd](https://linux.die.net/man/1/dd) to write the image to the USB drive: `sudo dd if=./pinpog of=/dev/<usb-drive>`

### Windows

<!-- TODO(#65): Bootable USB stick creation is not documented for Windows -->

## Controls

- `a`, `d` - move racket sideways,
- `f` - restart the game,
- `space` - toggle pause.

## References

- https://en.wikipedia.org/wiki/Mode_13h
- http://www.ctyme.com/intr/int.htm
- https://board.flatassembler.net/topic.php?t=14914

## Support

You can support my work via

- Twitch channel: https://www.twitch.tv/subs/tsoding
- Patreon: https://www.patreon.com/tsoding

[nasm]: https://www.nasm.us/
[qemu]: https://www.qemu.org/
