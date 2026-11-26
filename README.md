# enzyme-benchmarks

## Rust benchmarks

`gmm`, `lstm`, `ba`, `fft` and `ode-real` in `ReverseMode` also have a Rust
port, differentiated with [`std::autodiff`]. Each port has two variants, one
over slices and references (`src/safe.rs`) and one over raw pointers
(`src/unsf.rs`). They are built as a static library and timed by the same C++
driver as the other tools, where they show up as `Enzyme (Rust)` and
`Enzyme (unsafe Rust)`.

The Rust ports are off by default. To include them, set `BENCH_RUST=1` in the
environment when running a benchmark:

```sh
BENCH_RUST=1 ninja bench-gmm-reverse
```

This needs a nightly Rust toolchain with the `enzyme` component, which
`ReverseMode/rust-toolchain.toml` selects when cargo is run through rustup.
Set `CARGO` to use something else, e.g. `CARGO="cargo +my-toolchain"`.

Note that rustc differentiates with the Enzyme shipped in its toolchain, which
is not necessarily the Enzyme build the C++ side is using.

[`std::autodiff`]: https://doc.rust-lang.org/nightly/std/autodiff/index.html
