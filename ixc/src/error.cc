#include "error.hh"

bool Error::isOk() const {
    return code == 0 ? true : false;
}

bool Error::isError() const {
    return ! isOk();
}

Error Error::setCode(u32 errorCode) {
    code = errorCode;
    return *this;
}
