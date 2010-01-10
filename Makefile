SBDIR=~/sketchbook/hacksense

all: comm

comm: comm.c
	$(CC) comm.c -o comm

symlinks:
	mkdir -p $(SBDIR)/applet
	ln -s $$PWD/hacksense.pde $(SBDIR)

clean:
	rm -f *.o comm

.PHONY: all clean symlinks
