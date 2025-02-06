#include "error.hh"

bool Error::isOk() const {
    return code == 0 ? true : false;
}

bool Error::isError() const {
    return ! isOk();
}

Error Error::set(usize errorCode) {
    code = errorCode;
    return *this;
}

Error Error::setMessage(const char * errorMessage) {
    return *this;
}

Error Error::setLocation(const char * errorLocation) {
    return *this;
}
