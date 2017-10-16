#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "oxpc_utils.h"

void ERROR(
  const char* msg)
{
  fprintf(stderr, "%s\n", msg);
  exit(EXIT_FAILURE);
}

uint32_t
round_up_32(
  uint32_t base,
  uint32_t unit)
{
  return (base + (unit-1)) & (~(unit-1));
}
