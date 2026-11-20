# From Dirichlet nonvanishing to the Riemann hypothesis

[RhReduction.lean](RhReduction.lean) proves a conditional statement. Its input is the proposition called `UpperTheory.EveryCharacter` in the submission, written out so the check imports only Mathlib. The input says that a Dirichlet L-function has no zero with real part greater than ½, with an exception for the trivial character at 1. Its conclusion is Mathlib's `RiemannHypothesis`. The proof of the input itself remains a separate question.

## How the reduction works

Choose modulus one and its trivial character. Its L-function is the Riemann zeta function, so the hypothesis rules out zeta zeros to the right of the critical line. Consider a nontrivial zero to the left. The reflected point, obtained by subtracting the zero from 1, lies to the right. The functional equation for the completed zeta function carries the zero to that reflected point, producing a contradiction.

The exceptional points matter when passing between zeta and completed zeta. The original zero cannot be 0 because ζ(0) = −½, so its reflection cannot be 1. The gamma factor can vanish in Mathlib's convention at 0 and the negative even integers. The definition of a nontrivial zero excludes those negative even integers. This lets the proof pass from a zero of zeta to a zero of completed zeta. Only the critical line remains.

The submission's [rh_of_every](../src/Formalism/GammaFactorNonvanishing/CritLine.lean) specializes to the same character. Its [rh_of_right](../src/Formalism/GammaFactorNonvanishing/RhOfRight.lean) uses the uncompleted functional equation and checks when the cosine factor vanishes. This reproduction uses the completed functional equation, an approach also present in the submission's [other reduction](../src/Development/AutomorphicArithmetic/CharacterBoxes/RiemannHypothesisOfEveryCharacter.lean).

## Reproduce

From the repository root with Lean 4.33.1 and the checked-in Lake manifest (Mathlib commit `0df444a360eaa60ab8c11dca51a86af692955474`), run

```sh
lake exe cache get Mathlib.NumberTheory.LSeries.DirichletContinuation Mathlib.Tactic
lake env lean verification/RhReduction.lean
```

The final command checks the theorem and prints its axioms. The nonvanishing assumption appears as a parameter of the theorem.

## Local result

On 2026-11-20, against repository revision `a172c464fd4bcfc4f53e394dcba45d742b1409a6` plus this verification file, the Lean command exited with status 0 and printed

```text
'Verification.rh_of_character_nonvanishing' depends on axioms: [propext, Classical.choice, Quot.sound]
```
