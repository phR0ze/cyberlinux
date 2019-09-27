package reduce

type gKeysStruct struct {
	all        string // Build target: build all
	builder    string // Build target and deployment
	initramfs  string // Build target
	multiboot  string // Build target
	iso        string // Build target
	isofull    string // Build target: initramfs, multiboot and iso
	cyberlinux string // key
}
