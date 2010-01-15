SBDIR=~/sketchbook/hacksense
SIGNER_OBJECTS=signer.o hmac_sha2.o sha2.o

all: comm signer

signer: $(SIGNER_OBJECTS)
	$(CC) $(SIGNER_OBJECTS) -o signer

%.o: hmac/%.c
	$(CC) $< -c -o $@

%.o: %.c
	$(CC) $< -c -o $@

comm: comm.c
	$(CC) comm.c -o comm

symlinks:
	mkdir -p $(SBDIR)/applet
	ln -s $$PWD/hacksense.pde $(SBDIR)

hacksense.key: hacksense.key
	dd if=/dev/random of=hacksense.key bs=32 count=1

clean:
	rm -f *.o comm signer

.PHONY: all clean symlinks
