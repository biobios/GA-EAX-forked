# MIT License

# Copyright (c) 2025 BioBIOS

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

LIB_SRCS=$(wildcard src/lib/*.cpp)
LIB_OBJS=$(patsubst src/lib/%.cpp, temp/lib/%.o, $(LIB_SRCS))
DEBUG_LIB_OBJS=$(patsubst src/lib/%.cpp, temp/debug/lib/%.o, $(LIB_SRCS))
PROF_LIB_OBJS=$(patsubst src/lib/%.cpp, temp/prof/lib/%.o, $(LIB_SRCS))

PROJECTS:=$(patsubst src/%, %, $(filter-out src/lib, $(wildcard src/*)))
TARGETS:=$(addprefix bin/, $(PROJECTS))
DEBUG_TARGETS:=$(addprefix bin/debug/, $(PROJECTS))
PROF_TARGETS:=$(addprefix bin/prof/, $(PROJECTS))

export ROOT_DIR=$(shell pwd)
export LIB_NAME=mpilib
export CXXFLAGS=-I$(ROOT_DIR)/src/lib -std=c++23 -O3 -Wall -Wextra -pedantic -mtune=native -march=native

all: $(TARGETS)

$(TARGETS): bin/%: src/%/Makefile
	@$(MAKE) -C src/$*/

$(DEBUG_TARGETS): bin/debug/%: src/%/Makefile
	@$(MAKE) -C src/$*/ debug_build

$(PROF_TARGETS): bin/prof/%: src/%/Makefile
	@$(MAKE) -C src/$*/ prof_build

setup: $(patsubst %, src/%/Makefile, $(PROJECTS))

$(patsubst %, src/%/Makefile, $(PROJECTS)): src/%/Makefile: Makefile_template
	@cp $< $@

bin/lib$(LIB_NAME).a: $(LIB_OBJS)
	@mkdir -p $(dir $@)
	@ar rcs $@ $(LIB_OBJS)

bin/debug/lib$(LIB_NAME).a: $(DEBUG_LIB_OBJS)
	@mkdir -p $(dir $@)
	@ar rcs $@ $(DEBUG_LIB_OBJS)

bin/prof/lib$(LIB_NAME).a: $(PROF_LIB_OBJS)
	@mkdir -p $(dir $@)
	@ar rcs $@ $(PROF_LIB_OBJS)

$(LIB_OBJS): temp/lib/%.o: src/lib/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) -c $< -o $@ $(CXXFLAGS)

$(DEBUG_LIB_OBJS): temp/debug/lib/%.o: src/lib/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) -c $< -o $@ $(CXXFLAGS) -g -O0

$(PROF_LIB_OBJS): temp/prof/lib/%.o: src/lib/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) -c $< -o $@ $(CXXFLAGS) -pg

$(addprefix run/, $(PROJECTS)): run/%: src/%/Makefile
	@$(MAKE) -C src/$*/ run

$(addprefix prof_run/, $(PROJECTS)): prof_run/%: src/%/Makefile
	@$(MAKE) -C src/$*/ prof_run

clean:
	@rm -rf temp
	@rm -rf bin
	@rm -rf debug
	@rm -f src/*/Makefile

.PHONY: all clean setup $(TARGETS) $(DEBUG_TARGETS) $(PROF_TARGETS) $(addprefix run/, $(PROJECTS)) $(addprefix prof_run/, $(PROJECTS))