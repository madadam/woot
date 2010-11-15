DFLAGS = -I~/include -w -wi

image_viewer:
	cd examples && rdmd -of../bin/image_viewer $(DFLAGS) -I.. image_viewer.d

clean:
	rm -f *.o
	rm -f *.deps
	rm -f bin/*
