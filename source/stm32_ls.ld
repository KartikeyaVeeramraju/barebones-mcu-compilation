ENTRY(Reset_Handler)

MEMORY
{
    FLASH(rx):ORIGIN=0x08000000,LENGTH=1024K
    SRAM(rwx):ORIGIN:0x200000000,LENGTH=128K
}

__max_heap_size = 0x400; /* A symbol name and not a variable !!! */
__max_stack_size = 0x200; /* A symbol name and not a variable !!! */

SECTIONS
{
    .text : 
    {
        *(.isr_section) // initial code space must contain the vector table. Note that we only have one ISR vector section
        *(.text) // add all the .text sections of the .text section from all object files
        *(.rodata) 
        end_of_text = .; /* Store the updated location counter value into a symbol 'end_of_text' */
    }> FLASH

    .data :
    {
        *(.data)
    }> SRAM AT> FLASH

    .bss :
    {
        *(.bss)
    }> SRAM
}