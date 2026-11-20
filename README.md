# riemann-hypothesis

[![checks](https://github.com/qi1337/riemann-hypothesis/actions/workflows/checks.yml/badge.svg?branch=eisenstein)](https://github.com/qi1337/riemann-hypothesis/actions/workflows/checks.yml?query=branch%3Aeisenstein)

**Branch note.** This checkout applies a naming cleanup to the upstream mirror described below. Four fields of type `UnusedSlot72` now use the name `unusedSlot72`. The record constructor supplies `True.intro` directly, so the theorem named `siegel_eisenstein_simple_pole` is redundant and has been removed. The genuine pole-bound proposition keeps its original name and statement. CI applies the [exact patch](verification/pole-placeholder.patch) to the checksum-verified archive before comparing the source trees.

A [Comparator](https://github.com/leanprover/comparator) setup for the Lean formalization
claiming a proof of the Riemann Hypothesis and of GRH for Dirichlet L-functions, announced on
2026-11-20 at <https://alpo.ge/remark.pdf>.

The submission ships no challenge file that imports only Mathlib and no Comparator config.
The upstream mirror adds two files to the submission:

- [`src/Challenge.lean`](src/Challenge.lean) imports only Mathlib and states the five theorems.
- [`comparator.json`](comparator.json) is the Comparator config. The solution module is the submission's `Main`.

Everything else we wrote is in [`verification/`](verification/NOTES.md).

## Eisenstein pole check

The removed theorem concluded `True`. The residue argument obtains the pole bound it needs for its particular Eisenstein series from the vanishing of Laurent coefficients of order −2 and below. The general pole bound for every section is a separate proposition. [Coefficient statement](src/Development/WeilBound/RepresentationTheoryGL/RegularisedSiegelWeil/SingularNullSets/HasLevel.lean) · [Use in the residue calculation](src/Development/WeilBound/RepresentationTheoryGL/RegularisedSiegelWeil/ResidueVanishing/Rethread.lean)

From the repository root, run the standalone check with the pinned Lean toolchain:

```sh
lean verification/PoleSlot.lean
```

Lean exits successfully and prints `'UpperTheory.LiteratureTheorems.siegel_eisenstein_simple_pole' does not depend on any axioms`. The check copies the slot definition and theorem body and generalizes the unused argument type. It verifies that the proof can be replaced by `True.intro` and that `(UnusedSlot72 → P) ↔ P` for every proposition `P`. The downstream residue analysis above is a source trace. [Runnable check](verification/PoleSlot.lean) · [Original slot definition](https://github.com/Deicyde/riemann-hypothesis/blob/40e56bab026552e089d7afcfeff08d2defb9c005/src/Development/AutomorphicArithmetic/ThetaCorrespondence/ThetaPairLifts/LocalTypeDictionary/DiscreteSpectrumResidualClassification.lean#L7) · [Original theorem](https://github.com/Deicyde/riemann-hypothesis/blob/40e56bab026552e089d7afcfeff08d2defb9c005/src/Development/AutomorphicArithmetic/ThetaCorrespondence/ThetaPairLifts/ThirdPlaceSeries/EveryCharacterOfLiteratureOfVWin.lean#L505-L506)

Locally, applying the patch to the original mirror reproduced all six edited Lean files byte for byte. Lean 4.33.1 also accepted the standalone conditional reduction from Dirichlet nonvanishing to RH. The six edited modules and the full submission still require compilation on this branch. [Reproduction commands and output](verification/rh-reduction.md)

## Status

| Check | Result |
|---|---|
| Source matches the published tarball plus the branch cleanup | pending branch CI |
| Challenge compiles against Mathlib alone | pass (CI) |
| No `sorry`, `axiom`, `native_decide`, `unsafe`, `implemented_by` or `opaque` in the source | pass ([scan](verification/static-scan.txt)) |
| All nine dependency pins are official upstream commits | pass ([notes](verification/NOTES.md#dependencies)) |
| The Comparator route below, on a Mathlib-sized test | pass ([notes](verification/NOTES.md#smoke-test)) |
| **Comparator on the submission** | **not yet run**; the build is in progress and takes hours |

## The statements

`riemannHypothesis : RiemannHypothesis` uses Mathlib's own definition. The other four theorems
use four short definitions that `Challenge.lean` copies from the submission's `Statements.lean`:

- `riemannZeta_eq_zero_re`: RH again, written out.
- `LFunction_ne_zero_of_half_lt_re`: L(χ, s) ≠ 0 for Re s > 1/2, for every modulus and every
  Dirichlet character, except the trivial character at s = 1.
- `LFunction_eq_zero_re`: every zero of every L(χ, s) with 0 < Re s < 1 has Re s = 1/2.
- `LFunction_eq_zero_re_of_isPrimitive`: the same for primitive characters.

"GRH" here means Dirichlet L-functions only.

## Running Comparator

The project is pinned to Lean `v4.33.1`, and `lake comparator` exists only from Lean 4.35. So
the check has three steps: build with the project's own Lean, export the challenge and the
solution, and judge the two exports with Lean `v4.36.0`.

**1. Build**, with Lean `v4.33.1`, in a sandbox with no network (hours; read
[the build notes](verification/NOTES.md#building) first):

```bash
lake exe cache get          # Mathlib's official build cache; needs the network
lake build Main Challenge
```

**2. Export**, with [lean4export](https://github.com/leanprover/lean4export) at tag `v4.33.0`,
built with Lean `v4.33.1`:

```bash
THEOREMS="riemannHypothesis riemannZeta_eq_zero_re LFunction_ne_zero_of_half_lt_re LFunction_eq_zero_re LFunction_eq_zero_re_of_isPrimitive"
PRELUDE="propext Quot.sound Classical.choice Nat.add Nat.sub Nat.mul Nat.pow Nat.gcd Nat.div Nat.mod Nat.beq Nat.ble Nat.land Nat.lor Nat.xor Nat.shiftLeft Nat.shiftRight String.ofList Char.ofNat List eagerReduce Nat String String.mk Char optParam autoParam semiOutParam outParam"

lake env lean4export Challenge -- Quot Quot.mk Quot.lift Quot.ind $THEOREMS $PRELUDE > challenge.export
lake env lean4export Main      -- Quot Quot.mk Quot.lift Quot.ind $THEOREMS $PRELUDE > solution.export
```

**3. Judge**, with the official Lean `v4.36.0` toolchain on `PATH`, from an empty directory:

```bash
lake comparator --config comparator.json \
  --challenge-from-export challenge.export --solution-from-export solution.export
```

Comparator checks that the five statements match, that the proofs use only the three permitted
axioms, and that the proof is accepted by Lean's kernel and by the four checkers named in
`comparator.json`: Lean paranoid, nanoda, con-leche and con-ron.

### Why not `--paranoid`

`lake comparator --paranoid` runs those same four checkers plus lean4lean. Lean 4.36's lean4lean
rejects every export made by Lean 4.33.1 with `unknown constant 'Decidable.intro'`, because
4.36 redefined `Decidable` in the core library. The flag therefore fails on this project
whatever the proof contains. `comparator.json` names the other four checkers directly, and
lean4lean is run separately, built with Lean `v4.33.1`
([notes](verification/NOTES.md#lean4lean)).

## Limits

- Comparator checks the challenge and the solution against the same Mathlib, so it cannot
  detect a modified Mathlib. The pin here is Mathlib's official `v4.33.1` tag.
- The exports are made by Lean 4.33.1 and judged by Lean 4.36.0. Lean's help text lists exports
  made elsewhere as an intended use, and the export format version is the same (3.1.0), but
  this is not the common path.
- Lean 4.33.1 predates several kernel and runtime fixes
  ([notes](verification/NOTES.md#lean-version)), which is why the judging uses 4.36.0 and
  independent checkers.
- A passing run still trusts the checkers, Mathlib's definitions, Mathlib's official build
  cache, the exporter, and the sandboxes.

## License

The submission belongs to its author and was published without a license. It is mirrored here
unmodified, for verification only.
