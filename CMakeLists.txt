# Specify minimum CMake version required
cmake_minimum_required(VERSION 3.30.0 FATAL_ERROR)

# Set the C and C++ compilers to Clang
set(CMAKE_C_COMPILER /usr/lib/llvm-19/bin/clang)
set(CMAKE_CXX_COMPILER /usr/lib/llvm-19/bin/clang++)
set(CMAKE_CXX_STANDARD_LIBRARY libc++)

# Enables the Standard module support. This needs to be done
# before selecting the languages.
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
set(CMAKE_CXX_MODULE_STD ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -stdlib=libc++")

# Set C++ standard (e.g., C++17)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Specify the custom language compiler (hypothetical)
set(CPP2_COMPILER cppfront) # Replace with your actual compiler command
set(CPP2_FLAGS -import-std -import-cpp2-util)              # Any specific flags for the custom language

# Specify the build rules for cpp2 files
function(add_cpp2_file target cpp2_file is_module)
    # Define the output object file
    set(output_file "${CMAKE_CURRENT_BINARY_DIR}/${cpp2_file}.cpp")

    # Add a custom command to compile the .cpp2 file
    add_custom_command(
        OUTPUT ${output_file}
        COMMAND ${CPP2_COMPILER} ${CPP2_FLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/${cpp2_file} -o ${output_file}
        DEPENDS ${cpp2_file}
        COMMENT "Compiling ${cpp2_file} with ${CPP2_COMPILER}"
    )

    add_custom_target(cpp2_to_cpp_target_${cpp2_file}
        DEPENDS ${output_file}
    )
    add_dependencies(${target} cpp2_to_cpp_target_${cpp2_file})

    # Add the output object file to the target
    if(is_module)
        target_sources(${target} PRIVATE FILE_SET CXX_MODULES BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR} FILES ${output_file})
    else()
        target_sources(${target} PRIVATE ${output_file})
    endif()

endfunction()

#cmake_policy(SET CMP0167 NEW)
set(Boost_DIR /home/abell/.local/lib/cmake/Boost-1.83.0)

# Define the project name and version
project(advent2023 VERSION 1.0 LANGUAGES "CXX")

# Find Boost
find_package(Boost REQUIRED COMPONENTS program_options)

if(Boost_FOUND)
    add_executable(advent2023)

    target_include_directories(advent2023 PRIVATE ${Boost_INCLUDE_DIRS})
    target_link_libraries(advent2023 PRIVATE Boost::program_options)

    # Include directories
    include_directories(include)
    include_directories(/home/abell/src/cppfront/include)

    # Add subdirectory for the source files
    add_subdirectory(src)
else()
    message(FATAL_ERROR "Boost not found!")
endif()


