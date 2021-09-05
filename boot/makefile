CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds


bins = 
objs = kernel.o trapa.o liba.o main.o trap.o print.o debug.o memory.o process.o syscall.o lib.o keyboard.o

binaries = $(bins) $(objs)

DEPS = $(wildcard *.h)

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

%.o: %.asm
	nasm -f elf64 -o $@ $<

%.bin: %.asm
	nasm -f bin -o $@ $<


all: clean $(binaries)
	$(LD) $(LDFLAGS) -o kernel $(objs)
	objcopy -O binary kernel kernel.bin

run: all
	echo c | bochs
	# /mnt/c/Program\ Files/Bochs-2.7/bochs.exe -f 'S:\Programming\64bit_os\win_bochsrc.bxrc'

.PHONY: clean
clean:
	mv -f user1.bin user1.bin.keep
	mv -f console.bin console.bin.keep
	mv -f idle.bin idle.bin.keep
	
	rm -f *.o *.bin kernel
	
	mv -f user1.bin.keep user1.bin
	mv -f console.bin.keep console.bin
	mv -f idle.bin.keep idle.bin