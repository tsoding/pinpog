[![Build Status](https://travis-ci.org/tsoding/pinpog.svg?branch=master)](https://travis-ci.org/tsoding/pinpog)

# PinPog

Our goal is to write a game that fits into 512 bytes bootloader and
works in 16 bit real mode on any IBM PC compatible machine without any
Operating System.

- Development is done on https://twitch.tv/tsoding
- Archive of the streams: https://www.twitch.tv/collections/VAcjkyTlqRVXuA

![](https://i.imgur.com/2P9BAB0.png)

## Dependencies

- [nasm]
- [qemu]

## Quick Start

```console
$ nix-shell   # For NixOS
$ make
```


## Controls

- `a`, `d` - move racket sideways,
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
