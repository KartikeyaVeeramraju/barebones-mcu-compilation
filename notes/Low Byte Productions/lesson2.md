# Interrupts and Memory Mapped IO

## Register modifications in microcontrollers
1. memory map file should have all the base addresses 
	`source/LowByteProductions/libopencm3/include/libopencm3/stm32/f4/memorymap.h`
2. Memory mapped IO accessor functions in `source/LowByteProductions/libopencm3/include/libopencm3/cm3/common.h`
```
#define MMIO8(addr)		(*(volatile uint8_t *)(addr))
#define MMIO16(addr)		(*(volatile uint16_t *)(addr))
#define MMIO32(addr)		(*(volatile uint32_t *)(addr))
#define MMIO64(addr)		(*(volatile uint64_t *)(addr))
```
We are taking the address and casting to a 32 bit pointer for example in `MMIO32`. `volatile` keyword is here to tell teh compiler to not optimize anything here. Its a safety so compiler does not assume and optimize. The last * in the front is a dereference. So, we are 
3. When you call `gpio_mode_setup`, the function calls `moder = GPIO_MODER(gpioport);` which is pointer dereference to the offset addreess of the register. 
4. And by the end of the thing, it gives back the modified bits back to the register `GPIO_MODER(gpioport) = moder;` This is the main place where you are writing the value of the modified bits to the register.
5. Absolutely everything in the microcontroller is done by reading and writing to the memory mapped registers. 
6. Libopencm3 is really good but is not really necessary. We could directly talk to the registers using the technical reference manual. 


## Peripherals are awesome
From our first implementation, we blindly waited for 1 second before going again and toggling the system. Instead we can delegate this task to the systick timer and we can do something else pother than counting.   

`systick.h` has all this in libopencm3. 

- the processor say has 84 MHz base clock rate. So that is nanosecond time scale. 
- but what we are interested in is the millisecond time scale
- `systick_set_frequency(SYSTICK_FREQ, CPU_FREQ);` - will configure the systick with frequency and the clock rate of the cpu
- `systick_counter_enable();` - will make the timer start counting
- `systick_interrupt_enable();` -  interrupt whenever the timer is done
-  So at this point, you already have a function that will be called if the timer is done and this function is defined in systick.c - this is defined in `vector.h`
	`typedef void (*vector_table_entry_t)(void);` is the function pointer. So we have a series of those function pointers. 
- All the interrupts that can happen in the system are defined in `NVIC.h`
- The thing is, the systick interrupt is defined as 
	`#pragma weak sys_tick_handler = null_handler`
	As in it is a weak function and it can be overridden in user code base. 
- With 32 bits, we can only keep track of 50 days with the systick timer
- With 64 bits, you can keep track of really really long!
- Note that addition of two 64 bit instcuctions is two adds! So, something could happen during that time and data could be fragmented. So, we have to make it atomic. 
- So, the super simple solution is to disable all interrupts when we enter this function. 

