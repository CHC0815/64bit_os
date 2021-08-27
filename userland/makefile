
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
	$(LD) $(LDFLAGS) -o user $(objs) $(libs)
	objcopy -O binary user user.bin
	mv user.bin ../boot/user.bin

.PHONY: clean
clean:
	rm -f *.o *.a *.bin user