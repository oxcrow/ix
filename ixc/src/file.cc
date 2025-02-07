#include "file.hh"
#include "owned.hh"

/// Iterate till the end of file and count the number of characters
u32 readFileLength(FILE *file) {
    fseek(file, 0, SEEK_END);

    const u32 fileLength = ftell(file);

    fseek(file, 0, SEEK_SET);
    return fileLength;
}

Result<Owned<char *>> readFile(const char *filename) {
    Result<Owned<char *>> content;
    Result<Owned<char *>> error;
    error.error.setCode(1);

    FILE *file = fopen(filename, "r");
    if(! file) { return error; }

    const u32 fileLength = readFileLength(file);
    content.data.malloc(fileLength);
    fread(content.data.data, sizeof(char), fileLength, file);

    return content;
}
