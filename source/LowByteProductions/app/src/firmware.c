#include <libopencm3/cm3/cortex.h>
#include <libopencm3/cm3/nvic.h>
#include <libopencm3/cm3/systick.h>
#include <libopencm3/cm3/vector.h>
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

#define LED_PORT (GPIOA)
#define LED_PIN (GPIO5)

#define CPU_FREQ (84000000)
#define SYSTICK_FREQ (1000)
#define BLINK_PERIOD_MS (20)

// hey compiler, dont be smart about optimization with this variable...
volatile uint64_t ticks = 0;
static uint64_t get_ticks(void) { return ticks; }

void sys_tick_handler(void) {
  // one tick comes in, we come here
  ticks++;
}

static void rcc_setup(void) {
  rcc_periph_clock_enable(RCC_GPIOA);
  rcc_clock_setup_pll(&rcc_hsi_configs[RCC_CLOCK_3V3_84MHZ]);
}

static void gpio_setup(void) {
  // PA5 LED pin Setup
  gpio_mode_setup(LED_PORT, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO5);
}

static void systick_setup(void) {
  systick_set_frequency(SYSTICK_FREQ, CPU_FREQ);
  systick_interrupt_enable();
  systick_counter_enable();
}

// static void delay_cycles(uint32_t delay) {
//   for (uint32_t i = 0; i < delay; i++) {
//     __asm__("nop");
//   }
// }

int main(void) {
  rcc_setup();
  gpio_setup();
  systick_setup();

  cm_enable_interrupts();

  uint64_t start_time = get_ticks();

  while (1) {
    if (get_ticks() - start_time >= BLINK_PERIOD_MS) {
      gpio_toggle(LED_PORT, GPIO5);
      start_time = get_ticks();
    }
  }
  return 0;
}