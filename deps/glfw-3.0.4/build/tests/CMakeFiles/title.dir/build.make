# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/2.8.12.2/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/2.8.12.2/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The program to use to edit the cache.
CMAKE_EDIT_COMMAND = /usr/local/Cellar/cmake/2.8.12.2/bin/ccmake

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build

# Include any dependencies generated for this target.
include tests/CMakeFiles/title.dir/depend.make

# Include the progress variables for this target.
include tests/CMakeFiles/title.dir/progress.make

# Include the compile flags for this target's objects.
include tests/CMakeFiles/title.dir/flags.make

tests/CMakeFiles/title.dir/title.c.o: tests/CMakeFiles/title.dir/flags.make
tests/CMakeFiles/title.dir/title.c.o: ../tests/title.c
	$(CMAKE_COMMAND) -E cmake_progress_report /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building C object tests/CMakeFiles/title.dir/title.c.o"
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests && /usr/bin/gcc  -m64 -arch x86_64 $(C_DEFINES) $(C_FLAGS) -o CMakeFiles/title.dir/title.c.o   -c /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/tests/title.c

tests/CMakeFiles/title.dir/title.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/title.dir/title.c.i"
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests && /usr/bin/gcc  -m64 -arch x86_64 $(C_DEFINES) $(C_FLAGS) -E /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/tests/title.c > CMakeFiles/title.dir/title.c.i

tests/CMakeFiles/title.dir/title.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/title.dir/title.c.s"
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests && /usr/bin/gcc  -m64 -arch x86_64 $(C_DEFINES) $(C_FLAGS) -S /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/tests/title.c -o CMakeFiles/title.dir/title.c.s

tests/CMakeFiles/title.dir/title.c.o.requires:
.PHONY : tests/CMakeFiles/title.dir/title.c.o.requires

tests/CMakeFiles/title.dir/title.c.o.provides: tests/CMakeFiles/title.dir/title.c.o.requires
	$(MAKE) -f tests/CMakeFiles/title.dir/build.make tests/CMakeFiles/title.dir/title.c.o.provides.build
.PHONY : tests/CMakeFiles/title.dir/title.c.o.provides

tests/CMakeFiles/title.dir/title.c.o.provides.build: tests/CMakeFiles/title.dir/title.c.o

# Object files for target title
title_OBJECTS = \
"CMakeFiles/title.dir/title.c.o"

# External object files for target title
title_EXTERNAL_OBJECTS =

tests/title.app/Contents/MacOS/title: tests/CMakeFiles/title.dir/title.c.o
tests/title.app/Contents/MacOS/title: tests/CMakeFiles/title.dir/build.make
tests/title.app/Contents/MacOS/title: src/libglfw3.a
tests/title.app/Contents/MacOS/title: tests/CMakeFiles/title.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking C executable title.app/Contents/MacOS/title"
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/title.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tests/CMakeFiles/title.dir/build: tests/title.app/Contents/MacOS/title
.PHONY : tests/CMakeFiles/title.dir/build

tests/CMakeFiles/title.dir/requires: tests/CMakeFiles/title.dir/title.c.o.requires
.PHONY : tests/CMakeFiles/title.dir/requires

tests/CMakeFiles/title.dir/clean:
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests && $(CMAKE_COMMAND) -P CMakeFiles/title.dir/cmake_clean.cmake
.PHONY : tests/CMakeFiles/title.dir/clean

tests/CMakeFiles/title.dir/depend:
	cd /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4 /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/tests /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests /Users/hemantasapkota/Desktop/Projects/lo/lotech/deps/glfw-3.0.4/build/tests/CMakeFiles/title.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tests/CMakeFiles/title.dir/depend

