# RUN: cd %S && LD_LIBRARY_PATH="%bldpath:$LD_LIBRARY_PATH" BENCH="%bench" BENCHLINK="%blink" LOAD="%loadEnzyme" ENZYME="%enzyme" make -B ode-raw.ll ode-opt.ll results.json VERBOSE=1 -f %s

.PHONY: clean

dir := $(abspath $(lastword $(MAKEFILE_LIST))/../../../..)

clean:
	rm -f *.ll *.o results.txt results.json

# Set BENCH_RUST=1 to also benchmark the Rust port. This needs a nightly Rust
# toolchain with the enzyme component, see ../rust-toolchain.toml.
ifdef BENCH_RUST
CARGO ?= cargo
RUSTLIB := ../target/release/libode.a
RUSTDEF := -DBENCH_RUST

$(RUSTLIB): Cargo.toml src/lib.rs src/safe.rs src/unsf.rs
	RUSTFLAGS="-Zautodiff=Enable" $(CARGO) build --release -p ode
endif

%-unopt.ll: %.cpp
	clang++ $(BENCH) $(RUSTDEF) $^ -O2 -fno-use-cxa-atexit -fno-vectorize -fno-slp-vectorize -ffast-math -fno-unroll-loops -o $@ -S -emit-llvm

%-raw.ll: %-unopt.ll
	opt $^ $(LOAD) $(ENZYME) -o $@ -S

%-opt.ll: %-raw.ll
	opt $^ -o $@ -S

ode.o: ode-opt.ll $(RUSTLIB)
	clang++ $(BENCH) -O2 $^ -o $@ $(BENCHLINK)

results.json: ode.o
	./$^ 1000 | tee $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
	./$^ 1000 >> $@
