.PHONY: lib userland clean

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C lib clean
	$(MAKE) -C user1 clean
	$(MAKE) -C user2 clean
	$(MAKE) -C user3 clean
all:
	$(MAKE) -C boot all
run:
	$(MAKE) -C boot run
lib: 
	$(MAKE) -C lib lib
userland:
	$(MAKE) -C user1 all
	$(MAKE) -C user2 all
	$(MAKE) -C user3 all