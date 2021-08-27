.PHONY: lib userland clean

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C lib clean
	$(MAKE) -C userland clean
all:
	$(MAKE) -C boot all
run:
	$(MAKE) -C boot run
lib: 
	$(MAKE) -C lib lib
userland:
	$(MAKE) -C userland all