
clean:
	rm -rf zig-out zig-cache

build:
	zig build install -Dtarget=x86_64-freestanding
