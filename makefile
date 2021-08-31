.PHONY: lib userland clean

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
