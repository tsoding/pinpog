VERSION=1.0

.PHONY: all
all: pinpog
	qemu-system-i386 -monitor stdio pinpog

pinpog: pinpog.asm
	nasm pinpog.asm -o pinpog

.PHONY: dist

dist: pinpog-$(VERSION).tgz pinpog-$(VERSION).zip

pinpog-$(VERSION): pinpog README.release.md LICENSE
	mkdir pinpog-$(VERSION)
	cp pinpog pinpog-$(VERSION)/
	cp README.release.md pinpog-$(VERSION)/README.release.md
	cp LICENSE pinpog-$(VERSION)/

pinpog-$(VERSION).tgz: pinpog-$(VERSION)
	tar fvc pinpog-$(VERSION).tgz pinpog-$(VERSION)/

pinpog-$(VERSION).zip: pinpog-$(VERSION)
	zip -r pinpog-$(VERSION).zip pinpog-$(VERSION)

.PHONY: clean
clean:
	rm pinpog
