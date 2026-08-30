ASM = nasm
QEMU = qemu-system-x86_64

all: 01_hello.bin 02_menu.bin

%.bin: %.asm
	$(ASM) -f bin $< -o $@

run-hello: 01_hello.bin
	$(QEMU) -drive format=raw,file=01_hello.bin

run-menu: 02_menu.bin
	$(QEMU) -drive format=raw,file=02_menu.bin

clean:
	rm -f *.bin *.ppm *.png

.PHONY: all clean run-hello run-menu
