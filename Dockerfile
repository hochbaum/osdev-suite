FROM debian:stable
LABEL maintainer "Linus Hochbaum <linus@hochbaum.dev>"

RUN apt update && apt install -y \
	git \
	build-essential \
	ninja-build \
	libgmp-dev \
	libmpfr-dev \
	libmpc-dev \
	texinfo \
	bison \
	flex \
	libisl-dev \
	libtool \
	pkg-config \
	ninja-build \
	xorriso \
	python2 \
	nasm

RUN mkdir /tmp/suite
WORKDIR /tmp/suite
COPY tools ./

# Install binutils.
RUN cd tools/binutils-gdb && \
	mkdir build && \
	cd build && \
	../configure \
		--disable-debug \
		--diable-dependency-tracking \
		--prefix=/usr/local/x86_64-elf \
		--target=x86_64-elf \
		--disable-nls \
		--disable-werror \
		--with-sysroot && \
	make && \
	make install

# Update PATH environment variable to index our freshly cross-compiled
# x86_64-elf tools' binaries.
ENV PATH="${PATH}:/usr/local/x86_64-elf/bin"

# Install GCC.
RUN cd tools/gcc && \
	mkdir build && \
	cd build && \
	../configure \
		--target=x86_64-elf \
		--prefix=/usr/local/x86_64-elf \
		--enable-languages=c \
		--with-gnu-as \
		--with-gnu-ld \
		--with-ld=x86_64-elf-ld \
		--with-as=x86_64-elf-as \
		--disable-nls \
		--without-headers \
		--with-system-zlib && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc

# Small workaround to make sure we have a basic 'python' binary. GRUB's
# autoreconf.sh uses it. 
RUN ln -s /bin/python2 /bin/python

# Install GRUB2.
RUN cd tools/grub && \
	./bootstrap && \
	./autogen.sh && \
	mkdir build && \
	cd build && \
	../configure \
		TARGET_CC=x86_64-elf-gcc \
		TARGET_OBJCOPY=x86_64-elf-objcopy \
		TARGET_NM=x86_64-elf-nm \
		TARGET_STRIP=x86_64-elf-strip \
		TARGET_RANLIB=x86_64-elf-ranlb \
		--disable-werror \
		--prefix=x86_64-elf \
		--target=x86_64-elf && \
	make && \
	make install	

ENTRYPOINT ["/bin/bash"]
