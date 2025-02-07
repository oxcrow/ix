#include "common.hh"
#include "file.hh"

const char *header = " * ix *";

int main() {
    write("%s\n", header);

    const Result<Owned<char *>> code = readFile("../src/main.ix");
    ensure(code.isOk());

    return 0;
}
