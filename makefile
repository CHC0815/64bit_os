CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds


bins = boot.bin loader.bin
objs = kernel.o trapa.o liba.o main.o trap.o print.o debug.o memory.o

binaries = $(bins) $(objs)

DEPS = $(wildcard *.h)

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

%.o: %.asm
	nasm -f elf64 -o $@ $<

%.bin: %.asm
	nasm -f bin -o $@ $<


all: $(binaries)
	$(LD) $(LDFLAGS) -o kernel $(objs)
	objcopy -O binary kernel kernel.bin
	dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc
	dd if=kernel.bin of=boot.img bs=512 count=100 seek=6 conv=notrunc

run: clean all
	echo c | bochs

.PHONY: clean
clean:
	rm *.o *.bin kernel