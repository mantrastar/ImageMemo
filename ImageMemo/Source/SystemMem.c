//
//  SystemMem.c
//  ImageMemo
//
//  Created by Ven Jandhyala on 1/3/24.
//


#include "SystemMem.h"

#include <stdatomic.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>

#include "cache.h"
#include "cache_callbacks.h"

#include "mach/kern_return.h"
#if TARGET_OSX
#include "mach/mach_vm.h"
#endif
#include "mach/vm_map.h"

