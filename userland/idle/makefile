PROG_NAME = idle

CC = gcc
LD = ld
INCLUDES = -I. -I../../lib/
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone $(INCLUDES)
LDFLAGS = -nostdlib -T link.lds

libs = ../../lib/lib.a
objs = start.o main.o

%.o : %.asm
	nasm -f elf64 -o $@ $<

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

all: clean $(objs)
	$(LD) $(LDFLAGS) -o $(PROG_NAME) $(objs) $(libs)
	objcopy -O binary $(PROG_NAME) $(PROG_NAME).bin
	mv -f $(PROG_NAME).bin ../../boot/$(PROG_NAME).bin

.PHONY: clean
clean:
	rm -f *.o *.a *.bin $(PROG_NAME)