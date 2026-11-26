# RUN: cd %S && LD_LIBRARY_PATH="%bldpath:$LD_LIBRARY_PATH" BENCH="%bench" BENCHLINK="%blink" LOAD="%loadEnzyme" LOADCLANG="%loadClangEnzyme" ENZYME="%enzyme" make -B ba-raw.ll results.json -f %s

.PHONY: clean

dir := $(abspath $(lastword $(MAKEFILE_LIST))/../../../..)

clean:
	rm -f *.ll *.o results.txt results.json

# Set BENCH_RUST=1 to also benchmark the Rust port. This needs a nightly Rust
# toolchain with the enzyme component, see ../rust-toolchain.toml.
ifdef BENCH_RUST
CARGO ?= cargo
RUSTLIB := ../target/release/libbars.a
RUSTDEF := -DBENCH_RUST

$(RUSTLIB): Cargo.toml src/lib.rs src/safe.rs src/unsf.rs
	RUSTFLAGS="-Zautodiff=Enable" $(CARGO) build --release -p bars
endif

%-unopt.ll: %.cpp
	clang++ $(BENCH) $(RUSTDEF) $^ -pthread -O2 -fno-vectorize -fno-slp-vectorize -ffast-math -fno-unroll-loops -o $@ -S -emit-llvm

%-raw.ll: %-unopt.ll
	opt $^ $(LOAD) $(ENZYME) -o $@ -S

%-opt.ll: %-raw.ll
	opt $^ -o $@ -S

ba.o: ba-opt.ll $(RUSTLIB)
	clang++ $(BENCH) -pthread -O2 $^ -I /usr/include/c++/11 -I/usr/include/x86_64-linux-gnu/c++/11 -O2 -o $@ $(BENCHLINK) -lpthread -lm -L /usr/lib/gcc/x86_64-linux-gnu/11

results.json: ba.o
	./$^
