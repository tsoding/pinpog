# PinPog

## Dependencies

- [nasm]
- [qemu]

## Quick Start

```console
$ nix-shell   # For NixOS
$ make
```

<!-- TODO(#15): game controls are not documented -->

## References

- https://en.wikipedia.org/wiki/Mode_13h
- http://www.ctyme.com/intr/int.htm

[nasm]: https://www.nasm.us/
[qemu]: https://www.qemu.org/

## Building on MacOS

1. `brew install nasm`
2. `brew install qemu`

### Running

1. `make`

There should be an emulator window that fires up called
"qemu-system-i386" (which doesn't automatically refocus to the foreground).
