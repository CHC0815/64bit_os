CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds

bins = loader.bin
objs = entry.o liba.o main.o print.o debug.o 

binaries = $(bins) $(objs)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

%.o: %.asm
	nasm -f elf64 -o $@ $<

%.bin: %.asm
	nasm -f bin -o $@ $<

all: clean $(binaries)
	$(LD) $(LDFLAGS) -o entry $(objs)
	objcopy -O binary entry entry.bin
	dd if=entry.bin >> loader.bin
	dd if=loader.bin of=../os.img bs=512 count=15 seek=1 conv=notrunc

.PHONY: clean
clean:
	rm -f *.o *.bin entry