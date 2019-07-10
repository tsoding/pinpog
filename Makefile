.PHONY: all
all: pinpog
	qemu-system-i386 -monitor stdio pinpog

pinpog: pinpog.asm
	nasm pinpog.asm -o pinpog

.PHONY: clean
clean:
	rm pinpog
