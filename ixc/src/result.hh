#pragma once

struct Error;

/// Result type for efficiently handling errors
template<typename T>
struct Result {
    T data;
    Error error;
};
