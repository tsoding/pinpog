# PinPog

Our goal is to write a game that fits into 512 bytes bootloader and
works in 16 bit real mode on any IBM PC compatible machine without any
Operating System.

- Development is done on https://twitch.tv/tsoding
- Archive of the streams: https://www.twitch.tv/collections/VAcjkyTlqRVXuA

## Dependencies

- [nasm]
- [qemu]

## Quick Start

```console
$ nix-shell   # For NixOS
$ make
```

<!-- TODO(#15): game controls are not documented -->

## Controls

Use `a` and `d` to move racket sideways.
You can pause and unpause game by pressing `space`.
If you've lost, press `space` to restart the game.

## References

- https://en.wikipedia.org/wiki/Mode_13h
- http://www.ctyme.com/intr/int.htm

## Support

You can support my work via

- Twitch channel: https://www.twitch.tv/subs/tsoding
- Patreon: https://www.patreon.com/tsoding

[nasm]: https://www.nasm.us/
[qemu]: https://www.qemu.org/
