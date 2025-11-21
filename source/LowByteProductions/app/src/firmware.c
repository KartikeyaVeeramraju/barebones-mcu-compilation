#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

#define LED_PORT (GPIOA)
#define LED_PIN (GPIO5)

static void rcc_setup(void) {
  rcc_periph_clock_enable(RCC_GPIOA);
  rcc_clock_setup_pll(&rcc_hsi_configs[RCC_CLOCK_3V3_84MHZ]);
}

static void gpio_setup(void) {
  // PA5 LED pin Setup
  gpio_mode_setup(LED_PORT, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO5);
}

static void delay_cycles(uint32_t delay) {
  for (uint32_t i = 0; i < delay; i++) {
    __asm__("nop");
  }
}

int main(void) {
  rcc_setup();
  gpio_setup();
  while (1) {
    gpio_toggle(LED_PORT, GPIO5);
    delay_cycles(84E+6 / 4 / 2);
  }
  return 0;
}