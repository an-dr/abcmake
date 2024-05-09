#include <stdio.h>
#include "hello_consts.h"
#include "world.hpp"

void hello(){
    printf(HELLO_STR);
    world();
}
