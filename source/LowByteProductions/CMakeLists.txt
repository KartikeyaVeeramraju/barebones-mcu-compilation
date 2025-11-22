cmake_minimum_required(VERSION 3.16)
project(firmware C ASM)

# -------------------------------------------------------------
# Toolchain
# -------------------------------------------------------------
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN arm-none-eabi)
set(CMAKE_C_COMPILER ${TOOLCHAIN}-gcc)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN}-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN}-objcopy)

# -------------------------------------------------------------
# C Compiler Flags
# -------------------------------------------------------------
set(CMAKE_C_FLAGS "-mcpu=cortex-m4 -mthumb -O2 -ffunction-sections -fdata-sections -DSTM32F4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables")


# -------------------------------------------------------------
# Linker Flags
# -------------------------------------------------------------
set(CMAKE_EXE_LINKER_FLAGS "-T ${CMAKE_SOURCE_DIR}/app/linkerscript.ld -Wl,--gc-sections -nostdlib -nostartfiles -nodefaultlibs -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16")


# Override default C runtime libs
set(CMAKE_C_STANDARD_LIBRARIES "-lc -lnosys")

# -------------------------------------------------------------
# Build libopencm3 using its existing Makefile
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
# Firmware sources
# -------------------------------------------------------------
include_directories(
    ${CMAKE_SOURCE_DIR}/app/inc
    ${CMAKE_SOURCE_DIR}/libopencm3/include
)

add_executable(firmware.elf
    app/src/firmware.c
)

# Ensure libopencm3 builds first
add_dependencies(firmware.elf libopencm3_project)

# Link firmware
target_link_libraries(firmware.elf
    ${OPENCM3_LIB}
    c
    nosys
)

# -------------------------------------------------------------
# Generate firmware.bin
# -------------------------------------------------------------
add_custom_command(TARGET firmware.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary firmware.elf firmware.bin
    COMMENT "Generating firmware.bin"
)
