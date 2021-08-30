
CC = gcc
LD = ld
CFLAGS = -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone
LDFLAGS = -nostdlib -T link.lds

objs = syscall.o print.o lib.o

%.o : %.asm
	nasm -f elf64 -o $@ $<

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

lib: clean $(objs)
	ar -rcs lib.a $(objs)

.PHONY: clean
clean:
	rm -f *.o *.a