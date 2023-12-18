
clean:
	rm -rf zig-out zig-cache

build:
	zig build install -Dtarget=x86-freestanding

qemu:
	# https://forum.osdev.org/viewtopic.php?f=1&t=33638
	# -machine type=pc-i440fx-3.1
	qemu-system-x86_64 -kernel zig-out/bin/my-kernel
