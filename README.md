# x86 Bootloader

A 512-byte boot sector written in raw 16-bit x86 assembly (NASM) that runs directly on bare metal or QEMU — with no operating system, no C runtime, and no external libraries.

![Boot menu screenshot](menu_screen1.png)

## Overview

When the system boots, this program displays a `"Hello, World!"` splash screen and prompts for a keypress. Once pressed, it transitions into an interactive text menu with live options (Message, About, and Hardware Reboot).

Everything fits within the strict 512-byte Master Boot Record (MBR) limit and ends with the mandatory `0x55AA` boot signature.

## What's Here

| File | Description |
|---|---|
| [`bootloader/02_menu.asm`](bootloader/02_menu.asm) | Single unified bootloader containing the startup splash + interactive menu + reboot handler |
| [`bootloader/Makefile`](bootloader/Makefile) | Build and QEMU run automation script |

---

## Boot Flow

```
Power On / Reset
       │
       ▼
BIOS POST & Device Selection
       │
       ▼
Loads 512 bytes from disk into memory (0x7C00)
       │
       ▼
Jumps to 0x7C00 (16-bit Real Mode)
       │
       ├─► Set up segment registers & stack
       ├─► Clear screen (BIOS INT 0x10, AH=0x00)
       ├─► Print "Hello, World! (from the bootloader)"
       ├─► Wait for keypress (BIOS INT 0x16, AH=0x00)
       │
       ▼
Enter Interactive Boot Menu
       ├─► [1] Display System Message
       ├─► [2] Display About Info
       └─► [3] Pulse 8042 Keyboard Controller (Port 0x64, 0xFE) to Reboot
```

---

## Technical Highlights

- **16-Bit Real Mode**: Manual setup of segment registers (`DS`, `ES`, `SS`) and stack pointer (`SP = 0x7C00`).
- **BIOS Interrupts**:
  - `INT 0x10` (AH=0x0E): Teletype video character printing.
  - `INT 0x10` (AX=0x0003): Video mode reset for instant screen clears.
  - `INT 0x16` (AH=0x00): Blocking keyboard input.
- **Hardware Reboot**: Direct port I/O (`out 0x64, 0xFE`) to trigger a hard reset via the keyboard controller line.
- **Strict Size Constraint**: Fits entirely within 510 code/data bytes + 2-byte signature (`0xAA55`).

---

## Building and Running

### Prerequisites
- **NASM** (Netwide Assembler)
- **QEMU** (`qemu-system-x86_64`)

```bash
# On Debian/Ubuntu / WSL:
sudo apt install nasm qemu-system-x86
```

### Build & Run in QEMU
```bash
cd bootloader

# Build the 512-byte binary
make

# Boot in QEMU
make run
```

### Run on Bare Metal (Real Hardware)
> [!WARNING]
> This command will completely overwrite the target disk. Double check your drive identifier before running.

```bash
# Write directly to a USB drive (replace sdX with your drive)
sudo dd if=bootloader/02_menu.bin of=/dev/sdX bs=512 status=progress && sync
```
Boot your computer from the USB drive in **Legacy / CSM mode** (since this targets classic BIOS, not UEFI).

---

## Future Roadmap

- [ ] Stage-2 bootloader that loads subsequent disk sectors into memory
- [ ] Transition from 16-bit Real Mode to 32-bit Protected Mode (GDT setup)
- [ ] Jump into a minimal bare-metal C kernel
