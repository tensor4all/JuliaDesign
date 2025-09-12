# Considerations for the future plan

Hiroshi Shinaoka

## Purposes
The following are the purposes of future developments:

- Use safe default settings (no densitymatrix algorithm, smaller default truncation error, etc.)
- Fix the weird notation for cutoff in terms of squared norm
- Implement original contraction algorithms
- Unified treatment of MPS and MPO
- ...

## Possible options

1. Implement our own tensor network structure, and use `ITensors.ITensor` as an internal data structure.
2. Implement our own indexing structure, `ITensor`-like structure, and tensor network structure using only `NDTensors.jl`.
3. Switch to hybrid indexing structure

From top to bottom, the options are less ITensor-dependent.

## Background knowledge
The dependencies of `ITensors.jl` are not big since most functionalities have been separated from `ITensors.jl`.
The dependence of `ITensors.jl` means that the user of our library needs to cite the ITensor paper as well.
But, a citation is not a big problem.


## Considerations

### Option 1

- Pros
  - We can convert our tensor network object to an ITensor object and vice versa easily.
  - Smooth transition from `ITensorMPS.jl`
  - Less code to maintain.

- Cons
  - The user needs to cite the ITensor paper.
  - Our development can be considered as a part of ITensor's development.

### Option 2

- Pros
  - No dependency on `ITensors.jl`. 
  - If we reimplement the same indexing structure as `ITensors.jl`, we can convert our tensor network object to an ITensor object and vice versa easily.
  - Still less code to maintain.

- Cons
  - The user may be still encouraged to cite the ITensor paper as `NDTensors.jl` is maintained by the `ITensors.jl` team.

### Option 3
- Pros
  - Full control
  - Compatible with the Rust ecosystem.

- Cons
  - We are not sure that the hybrid indexing structure is better than the ITensor's indexing structure.

### My considerations
At this moment, I would prefer Option 1 or 2.
If we become confident about the hybrid indexing structure, we can switch to Option 3.

`ITensors.jl` is not a big library, and I do not think there will be frequent future major changes.
The library contains `TagSets` (tag sets), `ITensor` (general tensor type) and some other utilities such as `SmallStrings` (fixed length strings) for tags.
`TagSets` and `SmallStrings` have been effectively separated from the main source code and are available [here](https://github.com/ITensor/ITensors.jl/tree/main/src/lib).
We can copy them for our own library, or reimplement them if necessary.
Alternatively, we can simply dependent on `ITensors.jl`.

I am quite satisfied with the current design of `ITensor`, which is very dynamic.
A possible disadvantage is that the design is too dynamic, and may be difficult to integrate into C++ and Fortran codes.
At some point, we may replace the backend (i.e., contraction algorithms) by optimized implementations written in Rust.