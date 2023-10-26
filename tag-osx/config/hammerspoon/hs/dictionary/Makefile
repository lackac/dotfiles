LIB = libdictionary
SOURCE = $(LIB).m
TARGET = ../$(LIB).dylib
HS_FRAMEWORKS = /Applications/Hammerspoon.app/Contents/Frameworks

$(TARGET): $(SOURCE)
	clang $(SOURCE) -fmodules -fobjc-arc \
	  -F $(HS_FRAMEWORKS) \
	  -dynamiclib -undefined dynamic_lookup \
	  -o $(TARGET)

clean:
	rm $(TARGET)

.PHONY: clean
