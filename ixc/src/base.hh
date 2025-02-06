#pragma once
#include <stdint.h>

#define IXC_VERSION_MAJOR    0
#define IXC_VERSION_MINOR    0
#define IXC_VERSION_REVISION 1

/// Using a macro indirection allows us to later switch out printf
/// with something else such as sprintf or fprintf depending on our
/// unforseen use cases in near future or far away distant future.
/// For example we may want to print to both stderr and file.
#define write printf

/// The largest integer size that we will use to generate our
/// identifiers and indices for our AST nodes and iterations.
/// For now a 64 bit unsigned integer will be enough.
using usize = uint64_t;
