# cross compilation scheme taken from Eric Smith's spin2cpp compiler
# if CROSS is defined, we are building a cross compiler
# possible targets are: win32, rpi

ifeq ($(CROSS),win32)
  CC=i586-mingw32msvc-gcc
  CXX=i586-mingw32msvc-g++
  EXT=.exe
  BUILD=./build-win32
else ifeq ($(CROSS),rpi)
  CC=arm-linux-gnueabihf-gcc
  CXX=arm-linux-gnueabihf-g++
  EXT=
  BUILD=./build-rpi
else
  CC=gcc
  CXX=g++
  EXT=
  BUILD=./build
endif

TARGET = $(BUILD)/spinsim$(EXT)

SOURCES = spinsim.c spininterp.c spindebug.c pasmsim.c pasmdebug.c pasmsim2.c pasmdebug2.c eeprom.c debug.c gdb.c

ifneq ($(OS),msys)
SOURCES += conion.c
endif

OBJECTS = $(patsubst %,$(BUILD)/%, $(SOURCES:.c=.o))

# I'm not sure why these linker flags were being used but the break the build on Mac OS X so I've
# commented them out for the time being
#LDFLAGS = -Wl,--relax -Wl,--gc-sections
LDFLAGS =
OPT := -O3
CFLAGS  = -c -g -Wall -Wno-format $(OPT) -D LINUX

all: directory $(SOURCES) $(OBJECTS) Makefile
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJECTS)

directory:
	mkdir -p $(BUILD)

# Compile .c files into objexts .o
$(BUILD)/%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

clean: FORCE
	rm -rf $(BUILD)
FORCE:
