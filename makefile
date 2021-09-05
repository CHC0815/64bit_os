.PHONY: lib userland clean mount unmount

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C boot/loader clean
	$(MAKE) -C lib clean
	$(MAKE) -C userland/user1 clean
	$(MAKE) -C userland/console clean
	$(MAKE) -C userland/idle clean

all:
	$(MAKE) -C boot all
run:
	$(MAKE) -C boot run
lib: 
	$(MAKE) -C lib lib
userland:
	$(MAKE) -C userland/user1 all
	$(MAKE) -C userland/console all
	$(MAKE) -C userland/idle all
loader:
	$(MAKE) -C boot/loader all

mount:
	powershell.exe -Command "osfmount.com -a -t file -f .\boot\os.img -o rw -m O: -v 1"
unmount:
	powershell.exe -Command "osfmount.com -D -m O:"

copy: clean lib all userland loader mount
	sleep 10
	powershell.exe -Command "Copy-Item "boot/kernel.bin" -Destination "O:\kernel.bin" "
	sleep 2
	make unmount