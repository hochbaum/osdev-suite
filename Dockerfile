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
	python \
	nasm \
	zlib1g-dev \
	gettext \
	autopoint

RUN mkdir /tmp/suite
WORKDIR /tmp/suite
COPY tools ./

# Install binutils.
RUN cd binutils-gdb && \
	mkdir build && \
	cd build && \
	../configure \
		--disable-debug \
		--disable-dependency-tracking \
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
RUN cd gcc && \
	mkdir build && \
	cd build && \
	../configure \
		--target=x86_64-elf \
		--prefix=/usr/local/x86_64-elf \
		--enable-languages=c \
		--with-gnu-as \
		--with-gnu-ld \
		--with-ld=/usr/local/x86_64-elf/bin/x86_64-elf-ld \
		--with-as=/usr/local/x86_64-elf/bin/x86_64-elf-as \
		--disable-nls \
		--without-headers \
		--with-system-zlib && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc

# Install GRUB2.
RUN cd grub && \
	./bootstrap && \
	mkdir build && \
	cd build && \
	../configure \
		TARGET_CC=/usr/local/x86_64-elf/bin/x86_64-elf-gcc \
		TARGET_OBJCOPY=/usr/local/x86_64-elf/bin/x86_64-elf-objcopy \
		TARGET_NM=/usr/local/x86_64-elf/bin/x86_64-elf-nm \
		TARGET_STRIP=/usr/local/x86_64-elf/bin/x86_64-elf-strip \
		TARGET_RANLIB=/usr/local/x86_64-elf/bin/x86_64-elf-ranlb \
		--disable-werror \
		--prefix=/usr/local/x86_64-elf \
		--target=x86_64-elf && \
	make && \
	make install	

RUN rm -rf /tmp/suite
ENTRYPOINT ["/bin/bash"]
