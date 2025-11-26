#include <libopencm3/stm32/gpio.h>

#include "../inc/core/system.h"
#include "../inc/core/timer.h"

#define LED_PORT (GPIOA)
#define LED_PIN (GPIO5)

#define BRIGHTNESS_UPDATE_PRD_MS (10)

static void gpio_setup(void) {
  // PA5 LED pin Setup
  gpio_mode_setup(LED_PORT, GPIO_MODE_AF, GPIO_PUPD_NONE, LED_PIN);
  gpio_set_af(LED_PORT, GPIO_AF1, LED_PIN);
}

int main(void) {
  system_setup();
  gpio_setup();
  timer_setup();

  uint64_t start_time = system_get_ticks();

  float duty_cycle = 0.0F;

  while (1) {
    if (system_get_ticks() - start_time >= BRIGHTNESS_UPDATE_PRD_MS) {
      duty_cycle += 1.0F;
      if (duty_cycle > 100.0F) {
        duty_cycle = 0.0F;
      }
      timer_pwm_set_duty_cycle(duty_cycle);
      start_time = system_get_ticks();
    }
  }
  return 0;
}