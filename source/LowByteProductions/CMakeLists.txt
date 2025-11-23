cmake_minimum_required(VERSION 3.16)
project(firmware C ASM)

# -------------------------------------------------------------
# Project setup
# -------------------------------------------------------------
enable_language(C ASM)

# We assume the toolchain is provided via:
#   -DCMAKE_TOOLCHAIN_FILE=toolchain-arm-gcc.cmake
#
# i.e. build.sh does:
#   cmake -G Ninja -S . -B build -DCMAKE_TOOLCHAIN_FILE=toolchain-arm-gcc.cmake

# -------------------------------------------------------------
# Global compile options
# -------------------------------------------------------------
# Core + FPU + "bare-metal friendly" flags
add_compile_options(
    -mcpu=cortex-m4
    -mthumb
    -mfloat-abi=hard
    -mfpu=fpv4-sp-d16
    -O2
    -ffunction-sections
    -fdata-sections
    -fno-exceptions
    -fno-unwind-tables
    -fno-asynchronous-unwind-tables
)

# MCU / family defines
add_compile_definitions(
    STM32F4        # libopencm3 family
    STM32F446xx    # specific device (for your code / any CMSIS-y headers)
)

# -------------------------------------------------------------
# Linker options
# -------------------------------------------------------------
# Use your linker script and keep things lean.
# We use target_link_options (modern CMake) instead of global flags.
set(LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/app/linkerscript.ld")

# -------------------------------------------------------------
# libopencm3 build (via its own Makefile)
# -------------------------------------------------------------
include(ExternalProject)

ExternalProject_Add(libopencm3_project
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/libopencm3
    BINARY_DIR ${CMAKE_SOURCE_DIR}/libopencm3
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make TARGETS=stm32/f4
    INSTALL_COMMAND ""
    BUILD_BYPRODUCTS ${CMAKE_SOURCE_DIR}/libopencm3/lib/libopencm3_stm32f4.a
)

set(OPENCM3_LIB ${CMAKE_SOURCE_DIR}/libopencm3/lib/libopencm3_stm32f4.a)

# -------------------------------------------------------------
# Include paths
# -------------------------------------------------------------
include_directories(
    ${CMAKE_SOURCE_DIR}/app/inc
    ${CMAKE_SOURCE_DIR}/libopencm3/include
)

# -------------------------------------------------------------
# Firmware target
# -------------------------------------------------------------
add_executable(firmware.elf
    app/src/firmware.c
)

# Make sure libopencm3 is built first
add_dependencies(firmware.elf libopencm3_project)

# Link options specific to the firmware target
target_link_options(firmware.elf PRIVATE
    -T${LINKER_SCRIPT}
    -Wl,--gc-sections
    -nostdlib
    -nostartfiles
    -nodefaultlibs
    -mcpu=cortex-m4
    -mthumb
    -mfloat-abi=hard
    -mfpu=fpv4-sp-d16

    # Make absolutely sure the startup code and reset_handler are NOT gc'd
    -Wl,--undefined=reset_handler
)

# Libraries:
# - libopencm3: HAL / low-level stuff
# - c / nosys / m / gcc: C runtime, syscalls, math, builtins
target_link_libraries(firmware.elf PRIVATE
    ${OPENCM3_LIB}
    c
    nosys
    m
    gcc
)

# -------------------------------------------------------------
# Generate firmware.bin
# -------------------------------------------------------------
add_custom_command(TARGET firmware.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary firmware.elf firmware.bin
    COMMENT "Generating firmware.bin"
)
