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

#### Basic Usage

```bash
# Generate graph with default settings (libraries.toml -> libraries.svg)
julia generate_dependency_graph.jl

# Generate graph from a specific TOML file
julia generate_dependency_graph.jl libraries_design_current.toml
julia generate_dependency_graph.jl libraries_design_future.toml

# Specify custom output file name (prefix)
julia generate_dependency_graph.jl libraries_design_current.toml my_graph
# This generates: my_graph.svg

# Adjust canvas size (width and height in inches)
julia generate_dependency_graph.jl libraries_design_current.toml my_graph 12.0 8.0

# Show help message
julia generate_dependency_graph.jl -h
```

#### Examples

```bash
# Generate SVG from libraries_design_current.toml
julia generate_dependency_graph.jl libraries_design_current.toml
# Output: libraries_design_current.svg

# Generate SVG from libraries_design_future.toml with custom name
julia generate_dependency_graph.jl libraries_design_future.toml future_deps
# Output: future_deps.svg

# Generate large SVG (12 inches wide, 10 inches tall)
julia generate_dependency_graph.jl libraries_design_current.toml large_graph 12.0 10.0
# Output: large_graph.svg
```

#### TOML File Format

The TOML file should have the following structure:

```toml
[libraries]
LibraryName = { desc = "Description of the library", external = true }
AnotherLib = { desc = "Another description\nwith line breaks" }

[library_dependencies.LibraryName]
strong_deps = ["Dependency1", "Dependency2"]
weak_deps = ["OptionalDependency"]
test_deps = []
```

**Notes:**
- Use `\n` in the `desc` field to create line breaks in the SVG output
- Set `external = true` to mark external libraries (shown in red)
- `strong_deps` are shown with solid arrows
- `weak_deps` are shown with dashed arrows

#### Output

The script generates an SVG file with:
- **Solid arrows** for strong dependencies
- **Dashed arrows** for weak dependencies
- **Red nodes** for external libraries or libraries with external dependencies
- **HTML-formatted labels** with library names in bold and descriptions in smaller font

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