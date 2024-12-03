# Specify the executable and list of source files
add_cpp2_file(advent2023 cpp2util.cpp2 TRUE)
add_cpp2_file(advent2023 advent2023.cpp2 TRUE)
add_cpp2_file(advent2023 day1.cpp2 TRUE)
add_cpp2_file(advent2023 day2.cpp2 TRUE)
add_cpp2_file(advent2023 day3.cpp2 TRUE)
add_cpp2_file(advent2023 days.cpp2 TRUE)
add_cpp2_file(advent2023 main.cpp2 FALSE)

target_sources(advent2023 PRIVATE FILE_SET CXX_MODULES BASE_DIRS . FILES
                program_options.cpp)
target_sources(advent2023 PRIVATE FILE_SET CXX_MODULES BASE_DIRS . FILES
                parser.cpp)
