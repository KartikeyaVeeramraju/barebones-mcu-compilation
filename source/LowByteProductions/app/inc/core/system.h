#ifndef INC_SYSTEM_H
#define INC_SYSTEH_H

#include <stdint.h>

#define CPU_FREQ (84000000)
#define SYSTICK_FREQ (1000)

void system_setup(void);
uint64_t system_get_ticks(void);

#endif /* F7FE0E99_44C6_4AE8_B42B_F06C71406816 */
