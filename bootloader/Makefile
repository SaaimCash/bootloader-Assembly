ASM = nasm
QEMU = qemu-system-x86_64

all: 02_menu.bin

%.bin: %.asm
	$(ASM) -f bin $< -o $@

run: 02_menu.bin
	$(QEMU) -drive format=raw,file=02_menu.bin

clean:
	rm -f *.bin *.ppm *.png

.PHONY: all clean run
