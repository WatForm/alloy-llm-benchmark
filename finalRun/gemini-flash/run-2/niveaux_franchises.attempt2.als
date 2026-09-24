c->r->v in dl.coverages`?
Wait! Look at:
`one v: DeductibleValue | c->r->v in dl.coverages`
OR
`one c.(dl.coverages)[r]`
OR
`one dl.coverages[c, r]`
OR
`one v: DeductibleValue | dl.coverages[c, r] = v`?
Wait! What if we write:
`one dl.coverages[c, r]`?
Wait, is `one c.(dl.coverages)[r]` or `one r.(c.(dl.coverages))`?
Wait, let's check `c.(dl.coverages)`:
`dl.coverages` has type `Coverage -> RiskType -> DeductibleValue`.
`c.(dl.coverages)` has type `RiskType -> DeductibleValue`.
Then `c.(dl.coverages).DeductibleValue` or `r.(c.(dl.coverages))`?
Wait! In `r.(c.(dl.coverages))`:
`r` is joined with `c.(dl.coverages)`.
Since `c.(dl.coverages)` is `RiskType -> DeductibleValue`,
`r . (RiskType -> DeductibleValue)` gives `DeductibleValue`!
Wait, what about `c -> r -> DeductibleValue in dl.coverages`? No, that's not "exactly one".
What about:
`one v: DeductibleValue | c -> r -> v in dl.coverages`?
Wait! Let's think:
Does `one v: DeductibleValue | c -> r -> v in dl.coverages` mean:
There is exactly one `v` such that `(c, r, v) in dl.coverages`?
YES!
Is there ANY ambiguity in `one v: DeductibleValue | c -> r -> v in dl.coverages`?
NONE AT ALL! It is standard first-order logic quantified over `v: DeductibleValue`!
Wait, what about:
`all dl: DeductibleLevel, c: dl.product.base_coverages, r: RiskType | one v: DeductibleValue | c -> r -> v in dl.coverages`?
Wait, or in Alloy:
`all dl: DeductibleLevel, c: dl.product.base_coverages, r: RiskType | one v: DeductibleValue | dl -> c -> r -> v ...` if coverages was a top level relation, but here `coverages` is a field of `DeductibleLevel`.
So for a specific `dl`, `dl.coverages` is a relation of type `Coverage -> RiskType -> DeductibleValue`.
So `c -> r -> v in dl.coverages` is a ternary tuple in a ternary relation!
Wait, can you write `c -> r -> v