#include "../inc/core/timer.h"

#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/timer.h>

#include "../inc/core/system.h"

#define PRESCALER (84U)
#define DESIRED_FREQUENCY_HZ (1000U)
#define ARR_VALUE 1000U

void timer_setup(void) {
  rcc_periph_clock_enable(RCC_TIM2);

  // high level PWM configuration
  timer_set_mode(TIM2, TIM_CR1_CKD_CK_INT, TIM_CR1_CMS_EDGE, TIM_CR1_DIR_UP);

  // setup PWM mode
  timer_set_oc_mode(TIM2, TIM_OC1, TIM_OCM_PWM1);

  // enable pwm output
  timer_enable_counter(TIM2);
  timer_enable_oc_output(TIM2, TIM_OC1);

  // frequency setup
  timer_set_prescaler(TIM2, PRESCALER - 1);
  timer_set_period(TIM2, ARR_VALUE - 1);
}
void timer_pwm_set_duty_cycle(float duty_cycle) {
  // duty cycle =  (ccr / arr) * 100
  // ccr = (duty_cycle/100) * arr
  const float raw_value = (float)ARR_VALUE * (duty_cycle * 0.01F);
  timer_set_oc_value(TIM2, TIM_OC1, (uint32_t)raw_value);
}