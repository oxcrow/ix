#pragma once
#include "base.hh"
#include "owned.hh"

/// Error state for propagating errors.
///
/// Easily handle errors by storing the required error information
/// and using it to both check for errors, propagating errors up the
/// call stack, and crash at the end.
struct Error {
    usize code = 0;
    Owned<char *> message;
    Owned<char *> location;
    bool isOk() const;
    bool isError() const;
    Error set(usize errorCode);
    Error setMessage(const char *errorMessage);
    Error setLocation(const char *errorLocation);
};
