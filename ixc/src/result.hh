#pragma once

struct Error;

/// Result type for efficiently handling errors
template<typename T>
struct Result {
    T data;
    Error error;
    bool isOk() const;
    bool isError() const;
};

template<typename T>
bool Result<T>::isOk() const {
    return error.isOk();
}

template<typename T>
bool Result<T>::isError() const {
    return error.isError();
}
