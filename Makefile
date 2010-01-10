SBDIR=~/sketchbook/hacksense

all: comm signer

signer: signer.o hmac.o sha2.o
	$(CC) signer.o hmac.o sha2.o -o signer

hmac.o: hmac/hmac_sha2.c
	$(CC) hmac/hmac_sha2.c -c -o hmac.o

sha2.o: hmac/sha2.c
	$(CC) hmac/sha2.c -c -o sha2.o

signer.o: signer.c
	$(CC) signer.c -c -o signer.o

uuid.o: uuid.c
	$(CC) uuid.c -c -o uuid.o

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
