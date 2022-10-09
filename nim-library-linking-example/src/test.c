#include "test.h"

int increment_global(int cnt)
{
  return my_global += cnt;
}

int decrement_global(int cnt)
{
  return my_global -= cnt;
}

int get_global(int cnt)
{
  return my_global;
}
