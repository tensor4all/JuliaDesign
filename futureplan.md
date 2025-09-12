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
  - Implementing the comptible code for `ITensor.ITensor` and `ITensors.Index` is not trivial. Since we are familiar with the code of `ITensors.jl`, clean implementation is not easy (licensing issues).
  - People may think that we are copying ITensor's design without acknowledgement.

### Option 3
- Pros
  - Full control
  - Compatible with the Rust ecosystem.
  - True independence.

- Cons
  - We are not sure that the hybrid indexing structure is better than the ITensor's indexing structure.

## Why I think Option 2 is not a good option
While Option 2 might seem appealing at first glance to avoid dependency on `ITensors.jl`, it actually creates more problems than it solves:

**The fundamental contradiction**: The main motivation for avoiding `ITensors.jl` dependency is often to maintain independence and avoid being seen as "just another ITensor-based library." However, Option 2 requires reimplementing `ITensors.Index` and `ITensor.ITensor` with the same design and functionality. This essentially means we're still following ITensor's design philosophy, just without the official dependency and acknowledgement. We would likely be criticized for "copying ITensor's design" rather than being praised for independence.

**Implementation complexity without clear benefits**: Reimplementing `ITensors.Index` and `ITensor.ITensor` is non-trivial, especially since we want to maintain compatibility for easy conversion and to ensure performance. The licensing issues are also complex - we'd still need to cite the ITensor paper since `NDTensors.jl` is maintained by the same team. So we're taking on significant implementation burden without actually achieving true independence.

**Maintenance overhead**: We would end up maintaining our own versions of core data structures that already exist and are well-tested in `ITensors.jl`. This increases our maintenance burden without providing clear value to users.

**Confusing ecosystem**: If we go with Option 2, we'd have three different indexing structures across our libraries, which would be confusing for users and developers.

**Better alternatives exist**: Option 1 provides the same benefits (easy conversion, smooth transition) with much less implementation effort. Option 3 offers true independence if we're confident about the hybrid indexing approach, though this is still unproven.

In summary, Option 2 gives us the worst of both worlds: the complexity of reimplementation without the benefits of true independence or the simplicity of using existing, well-tested code.

## Why Option 3 is too early
Option 3 is too early to consider.
Anyway, we need ITensor-compatible indexing structure first.
The practical usage of hybrid indexing structure is not clear yet.
We should first implement the hybrid indexing structure as a separate package, and do many experiments with it.

## My recommendation
I would recommend Option 1, using `ITensors.jl` as a strong dependency.
If a strong dependency on `ITensors.jl` is necessary for some small libraries such as `TCI.jl`, we are fine with a weak dependency.
For something like `Quantics.jl` and `TCIAlgorithms.jl`, strong dependency is necessary and makes our development easier.