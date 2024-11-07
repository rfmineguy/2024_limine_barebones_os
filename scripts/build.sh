function usage {
    echo "usage ./scripts/build.sh <command>";
    echo "Commands";
    echo "    get_limine - retrieve and build the limine bootloader";
    echo "    build      - build the sample kernel";
    echo "    qemu       - run kernel in qemu";
}

function get_limine {
    git clone https://github.com/limine-bootloader/limine.git --branch v8.x-binary --depth=1
    make -C limine
}

function handle_build {
    make build -f scripts/build.Makefile
}

function handle_qemu {
    qemu-system-x86_64 -cdrom out/image.iso -boot d -serial file:output.txt -vga std
}

function handle_qemu_debug {
    qemu-system-x86_64 -cdrom out/image.iso -boot d -serial file:output.txt -vga std -s -S
}

case $1 in
    build ) shift 1; handle_build $@ ;;
    get_limine ) shift 1; get_limine $@ ;;
    qemu ) shift 1; handle_qemu $@ ;;
    qemu_debug ) shift 1; handle_qemu_debug $@ ;;
    * ) usage ;;
esac
