#include "../inc/core/system.h"

#include <libopencm3/cm3/systick.h>
#include <libopencm3/cm3/vector.h>
#include <libopencm3/stm32/rcc.h>

// hey compiler, dont be smart about optimization with this variable...
volatile uint64_t ticks = 0;

void sys_tick_handler(void) {
  // one tick comes in, we come here
  ticks++;
}

void system_setup(void) {
  systick_set_frequency(SYSTICK_FREQ, CPU_FREQ);
  systick_interrupt_enable();
  systick_counter_enable();

  rcc_periph_clock_enable(RCC_GPIOA);

  rcc_clock_setup_pll(&rcc_hsi_configs[RCC_CLOCK_3V3_84MHZ]);
}
uint64_t system_get_ticks(void) { return ticks; }
