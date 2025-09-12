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

## On `ITensors.jl`
`ITensors.jl` is not a big library.
The dependencies of `ITensors.jl` are not big since most functionalities have been separated from `ITensors.jl`.
I do not think there will be frequent future major changes.

The library contains `TagSets` (tag sets), `ITensor` (general tensor type) and some other utilities such as `SmallStrings` (fixed length strings) for tags.
`TagSets` and `SmallStrings` have been effectively separated from the main source code and are available [here](https://github.com/ITensor/ITensors.jl/tree/main/src/lib).
We can copy them for our own library, or reimplement them if necessary.
Alternatively, we can simply dependent on `ITensors.jl`.

The dependence of `ITensors.jl` means that the user of our library needs to cite the ITensor paper as well.
Fine, it is not a big problem. Get more citations in my community :)

## Drawbacks of depending on a big external library
From my experience with ALPS and TRIQS, the following are the drawbacks of depending on a big external library:

- Sometimes, the external library is updated frequently, and our library needs to be updated frequently following their updates.
- If we use C++, depending on the external library includes a huge number of dependencies, and it is not easy to manage/install them manually. Installing is combersome, and often requires a lot of trial and error. Even worse, we fail to build some of them :(
- Some library is difficult to compile, e.g., because they require latest compilers.
- Even if you do not like the behavior of an external library, you cannot change it (like default algorithms for contraction, etc.)

How about `ITensors.jl`? 
It has dependencies on a limited number of libraries, and we can automatically manage them by the package manager.
I have never failed to install `ITensors.jl` with the package manager.
We do not some of the default beavior of `ITensorMPS.jl`, but we do not depend on it.


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
  - Implementing the comptible code for `ITensor.ITensor` and `ITensors.Index` is not trivial. Since we are familiar with the code of `ITensors.jl`, clean implementation is not easy.

### Option 3
- Pros
  - Full control
  - Compatible with the Rust ecosystem.

- Cons
  - We are not sure that the hybrid indexing structure is better than the ITensor's indexing structure.

### My considerations
At this moment, I would prefer Option 1 or 2 since we need ITensor-like indexing structure for smooth transition from `ITensorMPS.jl`.
Option 2 looks a reasonable option, but not trivial due to the licensing issues.

We are not sure that the hybrid indexing structure is better than the ITensor's indexing structure.
If we are confident about the hybrid indexing structure, we can switch to Option 3.
If we take Option 2 first, we will have three different indexing structures in our libraries, which is too confusing.

A reasonable option is start with Option 1, which requires a minimum maintenance effort.
This means we make `ITensors.jl` a strong dependency for our libraries.
Some people may think that T4A is a part of ITensor's development, but I do not think so.
Depending on `numpy` is a common practice in the Python community.

If anyone is not happy with the design of `ITensors.Index` or `ITensor.ITensor`, we should not take Option 1.