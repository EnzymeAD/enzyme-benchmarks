#![feature(autodiff)]
#![allow(non_snake_case)]

use std::autodiff::autodiff_reverse;

#[cfg(not(any(feature = "safe", feature = "unsf")))]
compile_error!("Enable at least one of: features `safe` or `unsf`");

#[cfg(feature = "safe")]
pub mod safe;
#[cfg(feature = "unsf")]
pub mod unsf;

static BA_NCAMPARAMS: usize = 11;

#[no_mangle]
pub extern "C" fn rust_dcompute_zach_weight_error(
    w: *const f64,
    dw: *mut f64,
    err: *mut f64,
    derr: *mut f64,
) {
    dcompute_zach_weight_error(w, dw, err, derr);
}

#[autodiff_reverse(dcompute_zach_weight_error, Duplicated, Duplicated)]
pub fn compute_zach_weight_error(w: *const f64, err: *mut f64) {
    let w = unsafe { *w };
    unsafe {
        *err = 1. - w * w;
    }
}
