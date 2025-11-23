#!/usr/bin/env bash
#
# -------------------------------------------------------------
#  build.sh — Unified build script for Embedded CMake Projects
#
#  Usage:
#    ./build.sh build [--ninja] [Debug|Release]
#    ./build.sh rebuild [--ninja] [Debug|Release]
#    ./build.sh clean
#
#    ./build.sh flash
#    ./build.sh size
#    ./build.sh objdump
#    ./build.sh gdb
#
#  Options:
#    --toolchain <file>   Override the toolchain file
#
#  Notes:
#    - ALWAYS forces CMake to use ARM GCC (arm-none-eabi-gcc)
#    - Fixes the root cause where CMake picks /usr/bin/cc
# -------------------------------------------------------------

set -e

BUILD_DIR="build"
GENERATOR="Unix Makefiles"
USE_NINJA=0
BUILD_TYPE="Release"
TOOLCHAIN_FILE="toolchain-arm-gcc.cmake"   # default

# -------------------------------
# Color Helpers
# -------------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

msg() {
    printf "${BLUE}==>${RESET} $1\n"
}

ok() {
    printf "${GREEN}[OK]${RESET} $1\n"
}

err() {
    printf "${RED}[ERR]${RESET} $1\n"
}

# -------------------------------
# Argument Parser
# -------------------------------
prev_arg=""
for arg in "$@"; do
    case $prev_arg in
        --toolchain)
            TOOLCHAIN_FILE="$arg"
            prev_arg=""
            continue
            ;;
    esac

    case $arg in
        --ninja)
            USE_NINJA=1
            ;;
        --toolchain)
            prev_arg="--toolchain"
            ;;
        Debug|debug)
            BUILD_TYPE="Debug"
            ;;
        Release|release)
            BUILD_TYPE="Release"
            ;;
        *)
            ACTION="$arg"
            ;;
    esac
done

# -------------------------------
# Select Ninja if requested
# -------------------------------
if [ $USE_NINJA -eq 1 ]; then
    if ! command -v ninja >/dev/null 2>&1; then
        err "Ninja not found! Install: sudo apt install ninja-build"
        exit 1
    fi
    GENERATOR="Ninja"
fi

# -------------------------------
# Toolchain file validation
# -------------------------------
if [ ! -f "$TOOLCHAIN_FILE" ]; then
    err "Toolchain file '$TOOLCHAIN_FILE' not found!"
    echo "Expected something like:"
    echo "  $TOOLCHAIN_FILE"
    echo "Or override with:"
    echo "  ./build.sh build --toolchain myfile.cmake"
    exit 1
fi

# Inform user
msg "Using toolchain: $TOOLCHAIN_FILE"

# -------------------------------
# Core Actions
# -------------------------------
do_clean() {
    msg "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    ok "Clean complete."
}

do_configure() {
    msg "Configuring project..."

    cmake -G "$GENERATOR" \
        -S . \
        -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE"

    ok "CMake configuration complete."
}

do_build() {
    msg "Building project..."
    
    if [ $USE_NINJA -eq 1 ]; then
        ninja -C "$BUILD_DIR"
    else
        cmake --build "$BUILD_DIR" -- -j$(nproc)
    fi

    ok "Build complete."
}

# -------------------------------
# Flash Firmware
# -------------------------------
do_flash() {
    BIN="$BUILD_DIR/firmware.bin"

    if [ ! -f "$BIN" ]; then
        err "No firmware.bin found. Build first."
        exit 1
    fi

    msg "Flashing firmware..."
    st-flash write "$BIN" 0x08000000
    ok "Flash complete."
}

# -------------------------------
# Size Info
# -------------------------------
do_size() {
    ELF="$BUILD_DIR/firmware.elf"

    if [ ! -f "$ELF" ]; then
        err "No firmware.elf found. Build first."
        exit 1
    fi

    msg "Firmware size:"
    arm-none-eabi-size "$ELF"
}

# -------------------------------
# Disassembly
# -------------------------------
do_objdump() {
    ELF="$BUILD_DIR/firmware.elf"

    if [ ! -f "$ELF" ]; then
        err "No firmware.elf found. Build first."
        exit 1
    fi

    OUT="$BUILD_DIR/firmware.lst"
    msg "Generating disassembly at $OUT"
    arm-none-eabi-objdump -d "$ELF" > "$OUT"
    ok "Disassembly generated."
}

# -------------------------------
# GDB Session
# -------------------------------
do_gdb() {
    ELF="$BUILD_DIR/firmware.elf"

    if [ ! -f "$ELF" ]; then
        err "No firmware.elf found. Build first."
        exit 1
    fi

    msg "Starting st-util..."
    st-util &
    ST_PID=$!
    sleep 1

    msg "Launching GDB..."
    arm-none-eabi-gdb "$ELF"

    kill $ST_PID
    ok "GDB session ended."
}

# -------------------------------
# Dispatcher
# -------------------------------
case "$ACTION" in
    build)
        do_configure
        do_build
        ;;
    clean)
        do_clean
        ;;
    rebuild)
        do_clean
        do_configure
        do_build
        ;;
    flash)
        do_flash
        ;;
    size)
        do_size
        ;;
    objdump)
        do_objdump
        ;;
    gdb)
        do_gdb
        ;;
    *)
        echo -e "${YELLOW}Usage:${RESET}"
        echo "  ./build.sh build [--ninja] [Debug|Release]"
        echo "  ./build.sh rebuild [--ninja] [Debug|Release]"
        echo "  ./build.sh --toolchain <file>"
        echo ""
        echo "  ./build.sh clean"
        echo "  ./build.sh flash"
        echo "  ./build.sh size"
        echo "  ./build.sh objdump"
        echo "  ./build.sh gdb"
        exit 1
        ;;
esac

ok "Done."
