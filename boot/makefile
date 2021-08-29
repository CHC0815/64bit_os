CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds


bins = boot.bin loader.bin
objs = kernel.o trapa.o liba.o main.o trap.o print.o debug.o memory.o process.o syscall.o lib.o

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
	dd if=user1.bin of=boot.img bs=512 count=10 seek=106 conv=notrunc
	dd if=user2.bin of=boot.img bs=512 count=10 seek=116 conv=notrunc

run: clean all
	echo c | bochs

.PHONY: clean
clean:
	mv -f user1.bin user1.bin.keep
	mv -f user2.bin user2.bin.keep
	
	rm -f *.o *.bin kernel
	
	mv -f user1.bin.keep user1.bin
	mv -f user2.bin.keep user2.bin