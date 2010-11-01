PROGRAM = example

COMMON_DFLAGS  = -I~/include
DEBUG_DFLAGS   = $(COMMON_DFLAGS) -w -wi
RELEASE_DFLAGS = $(COMMON_DFLAGS) -inline -release -O

ifdef RELEASE
DFLAGS = $(RELEASE_DFLAGS)
else
DFLAGS = $(DEBUG_DFLAGS)
endif

build:
	rdmd --build-only -of$(PROGRAM) $(DFLAGS) example.d

run: build
	./$(PROGRAM)

test:
	rdmd -unittest $(DFLAGS) example.d

clean:
	rm -f *.o
	rm -f *.deps
	rm -f $(PROGRAM)
