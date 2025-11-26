# PWM and Timers

- The idea of this lesson is to do smooth adjusting on LED brightness using PWM
- Moved system and clock setup into system.c/.h
- New object files can be directly added to make file by appending
	``` 
	OBJS		+= $(SRC_DIR)/$(BINARY).o
	OBJS		+= $(SRC_DIR)/core/system.o
	```
- In STM, General Purpose Timers TIM2 to TIM5 are the ones that can do both captures as well as PWMs

- We can make single pulse of fixed length or a periodic PWM vanilla pulse train
- get the output you want to PWM and lookup the timer that controls the output on that timer. For the board I am using PA5 is the GPIO pin. Therefore, the `TIM2_CH1` is the assigned pwm signal to it. 

- `timer_set_mode(TIM2, TIM_CR1_CKD_CK_INT, TIM_CR1_CMS_EDGE, TIM_CR1_DIR_UP);` will set up the PWM timer with TIM2 having full clock being given. This function affects control register 1 for TIM2

- PA5, which is the LED pin needs to be set as alternate function 01

