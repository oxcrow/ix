#pragma once
#include "common.hh"

Result<Owned<char *>> readFile(const char *filename);
