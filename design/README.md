# JuliaDesign

This repository contains tools and documentation for designing Julia libraries and visualizing their dependencies.

## Dependency Graph Generator

A tool to generate visual dependency graphs from TOML configuration files.

### Setup

```bash
# Activate project environment
julia --project=@.

# Install dependencies
julia -e "using Pkg; Pkg.instantiate()"
```

### Usage

```bash
# Generate graph with default settings (libraries.toml -> libdeps.svg)
julia generate_dependency_graph.jl

# Show help message
julia generate_dependency_graph.jl -h
```

---

## Design of Julia libraries

This document is a collection of thoughts on how to design Julia libraries.

* `TensorCrossInterpolation.jl` (no ITensor dependence)
* `QuanticsTCI.jl`<br>TCI for quantics. QFT MPOs are implemented as well.
* `TCIAlgorithms.jl`<br>Advanced algorithms for TCI. But, we currently implement only adaptive patching + TCI. Rename to something else? Such as `AdaptivePatchingTCI.jl`?
* `ProjMPSs.jl` (rename to PartitionedMPSs.jl, PartitionedMPS, SubDomainMPS)<br>This library implements adaptive patching of MPSs. We use `ITensorMPS.MPS` as an internal data structure. In the future, we may implement operations using TCI. `ITensorMPS.ProjMPS` exists, need to be renamed.
* `FastMPOContractions.jl`<br>This library implements a set of functionalities missing in `ITensorMPS.jl` such as MPO-MPO contractions. We use `ITensorMPS.MPS` and `ITensorMPS.MPO` as internal data structures. In the future, we may implement operations using TCI.
* `Quantics.jl`<br>Many things related to quantics. But, it is already messy.
  - `automul`<br>Element-wise multiplication or matrix multiplication. The current implemtation assumes quantics, but can be generalized.
  - `makediagonal`, `extractdiagonal`
  - utility functions for quantics tags, e.g., `x=1`, `x=2`.