#pragma once
#include "base.hh"

/// Error state for propagating errors.
///
/// Easily handle errors by storing the required error information
/// and using it to both check for errors, propagating errors up the
/// call stack, and crash at the end.
struct Error {
    u32 code = 0;
    bool isOk() const;
    bool isError() const;
    Error setCode(u32 errorCode);
};
