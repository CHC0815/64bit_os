
CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds

libs = ../lib/lib.a
objs = start.o main.o

%.o : %.asm
	nasm -f elf64 -o $@ $<

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

all: clean $(objs)
	$(LD) $(LDFLAGS) -o user1 $(objs) $(libs)
	objcopy -O binary user1 user1.bin
	mv -f user1.bin ../boot/user1.bin

.PHONY: clean
clean:
	rm -f *.o *.a *.bin user1