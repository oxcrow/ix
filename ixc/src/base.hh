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
using u64 = uint64_t;

/// The standard integer size consisting 32 bits
/// While it maybe more easier to use u64 everywhere it is also
/// going to consume excessive memory consumption because each u64
/// is 64 bytes and we do not need 64 bytes for everything.
/// Moreover u64 *will* harm cache efficiency if used without care.
/// Thus we use this 32 bit code when we can.
using u32 = uint32_t;

/// Smaller integer types for more efficiency in certain cases
/// Such as when we know that for Tokens lexed from our code we can
/// assume that the length of the identifiers will never be larger
/// than 255 thus we can represent them as u8 integers.
/// Use them only when appropriate.
using u16 = uint16_t;

/// Smol integer
using u8 = uint8_t;
