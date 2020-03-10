CC = i686-w64-mingw32-gcc
CXX = i686-w64-mingw32-g++
ASM := nasm
WINDRES := i686-w64-mingw32-windres
INCFLAGS += -I. -Ipsarc
ALLSRCFLAGS += $(INCFLAGS) -DGIT_TAG=\"$(GIT_TAG)\"
ASMFLAGS += $(ALLSRCFLAGS) -fwin32 -DWIN32
OPTFLAGS := -O2
CFLAGS +=
CFLAGS += $(ALLSRCFLAGS) -Wall -Wno-unused-value -Wno-format -DNDEBUG -DWIN32 -D_WIN32 -D_WINDOWS 
CFLAGS += -DMINGW_HAS_SECURE_API -DUNICODE -D_UNICODE -DNO_STRICT
CXXFLAGS += $(CFLAGS) -fpermissive
WINDRESFLAGS += $(ALLSRCFLAGS) --codepage=65001
LDFLAGS +=
LDLIBS += -static-libgcc -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic -Wl,--kill-at 

%.o: %.c
	@printf '\t%s %s\n' CC $<
	$(CC) -c $(CFLAGS) $(OPTFLAGS) -o $@ $<

%.o: %.cpp
	@printf '\t%s %s\n' CXX $<
	$(CXX) -c $(CXXFLAGS) $(OPTFLAGS) -o $@ $<

%.o: %.nas
	@printf '\t%s %s\n' ASM $<
	$(ASM) $(ASMFLAGS) $< -o$@ 

%.o: %.rc
	@printf '\t%s %s\n' WINDRES $<
	$(WINDRES) $(WINDRESFLAGS) $< $@

SOURCES := psarc/file.cpp psarc/libgen.c psarc/main.cpp psarc/psarc.cpp
SOURCES += external/zlib/adler32.c external/zlib/compress.c external/zlib/crc32.c external/zlib/deflate.c external/zlib/gzclose.c external/zlib/gzlib.c external/zlib/gzread.c external/zlib/gzwrite.c external/zlib/infback.c external/zlib/inffast.c external/zlib/inflate.c external/zlib/inftrees.c external/zlib/trees.c external/zlib/uncompr.c external/zlib/zutil.c
OBJECTS := $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.cpp=.o)
OBJECTS := $(OBJECTS:.nas=.o)
OBJECTS := $(OBJECTS:.rc=.o)

BINARY ?= psarc-tool.exe
ARCHIVE ?= psarc-tool.7z

all: $(BINARY)

archive: $(ARCHIVE)

clean:
	rm -f $(OBJECTS) $(BINARY) $(ARCHIVE)

$(ARCHIVE): $(BINARY)
	rm -f $(ARCHIVE)
	7z a $@ $^

$(BINARY): $(OBJECTS) 
	@printf '\t%s %s\n' LNK $@
	$(CXX) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)
