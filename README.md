# Design of Julia libraries

This document is a collection of thoughts on how to design Julia libraries.

* `TensorCrossInterpolation.jl`
* `TCIAlgorithms.jl`<br>Advanced algorithms for TCI. But, we currently implement only adaptive patching + TCI. Rename to something else? Such as `AdaptivePatchingTCI.jl`?
* `FastMPOContractions.jl`<br>This library implements a set of functionalities missing in `ITensorMPS.jl` such as MPO-MPO contractions. We use `ITensorMPS.MPS` and `ITensorMPS.MPO` as internal data structures. In the future, we may implement operations using TCI.
* `ProjMPSs.jl` (rename?)<br>This library implements adaptive patching of MPSs. We use `ITensorMPS.MPS` as an internal data structure. In the future, we may implement operations using TCI.
* `Quantics.jl`<br>Many things related to quantics. But, it is already messy.
  - `makediagonal`, `extractdiagonal`
  - `automul`
  - utility functions for tags, e.g., `x=1`, `x=2`.