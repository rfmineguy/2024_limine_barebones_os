function usage {
    echo "usage ./scripts/build.sh <command>";
    echo "Commands";
    echo "    get_limine - retrieve and build the limine bootloader";
    echo "    build      - build the sample kernel";
}

function get_limine {
    git clone https://github.com/limine-bootloader/limine.git --branch v8.x-binary --depth=1
    make -C limine
}

function handle_build {
    make build -f scripts/build.Makefile
}

case $1 in
    build ) shift 1; handle_build $@ ;;
    get_limine ) shift 1; get_limine $@ ;;
    * ) usage ;;
esac
