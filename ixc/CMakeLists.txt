set(mode 1)
cmake_minimum_required(VERSION 3.15)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

project(ixc C)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
file(GLOB_RECURSE source src/*.c)

add_compile_options(-pedantic)
add_compile_options(-Wall)
add_compile_options(-Wextra)
add_compile_options(-Wno-unused-variable)
add_compile_options(-Wno-unused-parameter)

if (${mode} EQUAL 0)
    message ("-- Enabling RELEASE mode")
    add_compile_options(-O2)
endif()

if (${mode} EQUAL 1)
    message ("-- Enabling DEBUG mode")
    add_compile_options(-g)
    add_compile_options(-fsanitize=address)
    add_compile_options(-fsanitize=undefined)
    add_link_options(-fsanitize=address)
    add_link_options(-fsanitize=undefined)
endif()

add_executable(ixc ${source})
