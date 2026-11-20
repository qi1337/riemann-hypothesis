abbrev GlobalTheory.Published.UnusedSlot72 : Prop := True

-- The original argument has type OpenLiteratureStatements. The proof ignores it.
theorem UpperTheory.LiteratureTheorems.siegel_eisenstein_simple_pole
    {Input : Sort u} (_ : Input) : GlobalTheory.Published.UnusedSlot72 :=
  trivial

example {Input : Sort u} (o : Input) :
    UpperTheory.LiteratureTheorems.siegel_eisenstein_simple_pole o = True.intro := rfl

example (P : Prop) : (GlobalTheory.Published.UnusedSlot72 → P) ↔ P :=
  ⟨fun f => f True.intro, fun p _ => p⟩

example : ¬ (GlobalTheory.Published.UnusedSlot72 → False) :=
  fun f => f True.intro

#print axioms UpperTheory.LiteratureTheorems.siegel_eisenstein_simple_pole
