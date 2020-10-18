project(newmarch_prolog)
cmake_minimum_required(VERSION 3.10)

set(prolog_interpreter_SRCS
   load.c
   main.c
   mem.c
   unify.c
   wam.c
)

add_executable(prolog_interpreter ${prolog_interpreter_SRCS})
