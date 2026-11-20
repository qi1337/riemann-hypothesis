import Mathlib.NumberTheory.LSeries.DirichletContinuation
import Mathlib.Tactic

namespace Verification

open Complex DirichletCharacter

/-- Conditional reduction using only the trivial character of modulus one. -/
theorem rh_of_character_nonvanishing
    (h : ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
      1 / 2 < s.re → (χ ≠ 1 ∨ s ≠ 1) → LFunction χ s ≠ 0) :
    RiemannHypothesis := by
  have right (z : ℂ) (hz : 1 / 2 < z.re) (hp : z ≠ 1) : riemannZeta z ≠ 0 := by
    simpa only [LFunction_modOne_eq] using h 1 1 z hz (Or.inr hp)
  intro s zero nontrivial regular
  rcases lt_trichotomy s.re (1 / 2) with left | onLine | above
  · have s0 : s ≠ 0 := by
      rintro rfl
      norm_num [riemannZeta_zero] at zero
    have gamma : Gammaℝ s ≠ 0 := by
      intro vanishes
      obtain ⟨n, hn⟩ := Gammaℝ_eq_zero_iff.mp vanishes
      cases n with
      | zero => exact s0 (by simpa using hn)
      | succ k =>
        apply nontrivial
        exact ⟨k, by rw [hn]; push_cast; ring⟩
    rw [riemannZeta_def_of_ne_zero s0, div_eq_zero_iff] at zero
    have completed := zero.resolve_right gamma
    have reflected : riemannZeta (1 - s) = 0 := by
      rw [riemannZeta_def_of_ne_zero (sub_ne_zero.mpr (Ne.symm regular)),
        completedRiemannZeta_one_sub, completed, zero_div]
    exact False.elim (right (1 - s) (by simp; linarith)
      (by intro e; apply s0; linear_combination -e) reflected)
  · exact onLine
  · exact False.elim (right s above regular zero)

#print axioms rh_of_character_nonvanishing

end Verification
