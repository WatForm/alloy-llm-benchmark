`all x: e1, y: e2 | F`
    "The scope of x includes e2? NO!"
    Wait! In Alloy, does `all x: A, y: x.b | ...` work?
    In older Alloy (and even Alloy 4/5/6), let's verify if `x` is in scope in `e2`!
    Wait! In many languages (like Alloy), in `all x: X, y: x.R | ...`, does it parse?
    Wait, let's be VERY CAREFUL.
    In Alloy, declarations in a quantifier:
    If you write:
    `all dl: DeductibleLevel | all c: dl.product.base_coverages | all r: RiskType | ...`
    This is GUARANTEED to be valid in every single version of Alloy, without any doubt!
    Nested `all` quantifiers:
    `all dl: DeductibleLevel | all c: dl.product.base_coverages | all r: RiskType | one dl.coverages[c][r]`
    Nested quantifiers are 100% safe and universally supported by every Alloy parser!

11. **Let's verify the dot join / box join syntax:**
    Is `dl.coverages[c][r]` completely safe?
    Wait, what is `c.(dl.coverages)`?
    `dl.coverages` has type `Coverage -> RiskType -> DeductibleValue`.
    Wait! If `coverages` is a field of `DeductibleLevel`:
    In `sig DeductibleLevel { coverages: Coverage -> RiskType -> DeductibleValue }`
    What is the type of `dl.coverages`?
    `dl` has type `DeductibleLevel`.
    `coverages` as a relation has type `DeductibleLevel -> Coverage -> RiskType -> DeductibleValue` (a 4-ary relation!).
    When you write `dl.coverages`:
    The dot join joins `DeductibleLevel` (arity 1) with `DeductibleLevel -> Coverage -> RiskType -> DeductibleValue` (arity 4).
    The result `dl.coverages` has arity 3: `Coverage -> RiskType -> DeductibleValue`.
    Now, what is `c.(dl.coverages)`?
    `c` has arity 1 (`Coverage`).
    Joining `c` with `Coverage -> RiskType -> DeductibleValue` gives `RiskType -> DeductibleValue` (arity 2).
    Now, what is `r.(c.(dl.coverages))`?
    Wait! `r` has arity 1 (`RiskType`).
    Joining `r` with `RiskType -> DeductibleValue`:
    `r.(...)` joins `r` on the FIRST column of `RiskType -> DeductibleValue`!
    So `r.(