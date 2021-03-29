# osdev-suite
This repository contains a Docker image for x86_64 OSDev. It contains x86_64-elf cross-compiled GCC, binutils and GRUB2 to
quickly get you started!

#### Setting up a suite
```
docker run -it --name my-osdev-suite hochbaum/osdev
```

#### Getting files out of the container
```
docker cp my-osdev-suite:/tmp/suite/myiso.iso .
```
