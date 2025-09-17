// *************************************************************************
//
// Copyright (c) 2024 Andrei Gramakov. All rights reserved.
//
// site:    https://agramakov.me
// e-mail:  mail@agramakov.me
//
// *************************************************************************

#include "exclamation.hpp"
#include "hello.hpp"
#include "world.hpp"
#include "ulog.h"

#include "app.hpp"

void app()
{
    hello();
    world();
    exclamation();
    ulog_info("Hello Microlog!");
}
