export BUILD_DIR = build

export target = riscv32_gdb

export SRC = \
src/gdb_server.c \
src/riscv_cpu_handle.c \
riscv32_gdb.c \

export SRC_FLAG =\
-Isrc \

export DEF = \
-D_DEBUG \
-DGDB_DBG