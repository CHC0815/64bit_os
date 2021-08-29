
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
	$(LD) $(LDFLAGS) -o user2 $(objs) $(libs)
	objcopy -O binary user2 user2.bin
	mv -f user2.bin ../boot/user2.bin

.PHONY: clean
clean:
	rm -f *.o *.a *.bin user2