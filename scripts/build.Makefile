KERNEL_SRC := src
OUT := out

C_KERNEL_SOURCE := $(wildcard $(KERNEL_SRC)/*.c)
S_KERNEL_SOURCE := $(wildcard $(KERNEL_SRC)/*.s)

C_SOURCES := $(C_KERNEL_SOURCE) $(C_STDLIB_SOURCE)
S_SOURCES := $(S_KERNEL_SOURCE) $(S_STDLIB_SOURCE)

C_OBJECTS := $(patsubst $(KERNEL_SRC)/%.c, $(OUT)/%.c.o, $(C_KERNEL_SOURCE)) $(patsubst $(STDLIB_SRC)/%.c, $(OUT)/%.c.o, $(C_STDLIB_SOURCE))
S_OBJECTS := $(patsubst $(KERNEL_SRC)/%.s, $(OUT)/%.s.o, $(S_KERNEL_SOURCE)) $(patsubst $(STDLIB_SRC)/%.s, $(OUT)/%.s.o, $(S_STDLIB_SOURCE))

BIN := os.bin
CC := x86_64-elf-gcc
LD := x86_64-elf-ld
AS := x86_64-elf-as

CFLAGS := -ffreestanding -nostdlib -Ilimine

.PHONY: build always limine
always:
	mkdir -p $(OUT)
build: always out/$(BIN) limine
limine:
	mkdir -p iso_root
	mkdir -p iso_root/boot
	cp -v out/os.bin iso_root/boot/
	mkdir -p iso_root/boot/limine
	cp -v limine.conf limine/limine-bios.sys limine/limine-bios-cd.bin \
	limine/limine-uefi-cd.bin iso_root/boot/limine/
	mkdir -p iso_root/EFI/BOOT
	cp -v limine/BOOTX64.EFI iso_root/EFI/BOOT/
	cp -v limine/BOOTIA32.EFI iso_root/EFI/BOOT/
	xorriso -as mkisofs -R -r -J -b boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
        -apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        iso_root -o $(OUT)/image.iso
	./limine/limine bios-install $(OUT)/image.iso

out/$(BIN): $(C_OBJECTS) $(S_OBJECTS)
	$(LD) -T linker.ld -o $@ $(C_OBJECTS) $(S_OBJECTS)

$(OUT)/%.c.o: $(KERNEL_SRC)/%.c
	$(CC) $(GCCFLAGS) -c $^ -o $@ $(CFLAGS) $(OPTIMIZATION_FLAGS) -Wall -Wextra -I$(KERNEL_SRC) -I$(STDLIB_SRC) -I$(OUT)/

$(OUT)/%.c.o: $(STDLIB_SRC)/%.c
	$(CC) $(GCCFLAGS) -c $^ -o $@ $(CFLAGS) $(OPTIMIZATION_FLAGS) -Wall -Wextra -I$(KERNEL_SRC) -I$(STDLIB_SRC) -I$(OUT)/

$(OUT)/%.s.o: $(KERNEL_SRC)/%.s
	$(AS) $(ASFLAGS) $^ -o $@

$(OUT)/%.s.o: $(STDLIB_SRC)/%.s
	$(AS) $(ASFLAGS) $^ -o $@
