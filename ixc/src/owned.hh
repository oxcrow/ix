#pragma once

#include <stdlib.h>
#include "base.hh"

/// Owned pointer that will be freed at the end of scope
///
/// Use this instead of raw pointers wherever the memory needs to be
/// manually managed. Use raw pointers *only* for reading/writing data
/// not for managing it.
template<typename T>
struct Owned {
    T *data;
    ~Owned();
    void malloc(uint64_t n);
    void free();
};

template<typename T>
Owned<T>::~Owned() {
    free();
}

template<typename T>
void Owned<T>::malloc(uint64_t n) {
    if(data) free();
    data = (T *) ::malloc(n * sizeof(T));
}

template<typename T>
void Owned<T>::free() {
    if(data) ::free(data);
}
