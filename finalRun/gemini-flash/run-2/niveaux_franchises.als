+ dl.product.optional_coverages) <: risk_types`?
Wait, does `{ c: dl.product.base_coverages + dl.product.optional_coverages, r: RiskType | r in c.risk_types }` equal `(dl.product.base_coverages + dl.product.optional_coverages) <: risk_types`?
Yes, they are identical!
Wait, what about the quantifier version:
`all dl: DeductibleLevel, c: Coverage, r: RiskType | (some dl.coverages[c][r]) iff (c in dl.product.base_coverages + dl.product.optional_coverages and r in c.risk_types)`?
Wait! What if `dl.coverages.DeductibleValue` is used?
Does Alloy 6 support `dl.coverages.DeductibleValue`?
YES, of course! Relational join `.` is the fundamental construct of Alloy.

Wait, let's check:
Can `all dl: DeductibleLevel | ...` be written inside `DeductibleLevel` or in a `fact`?
Wait, if written inside `sig DeductibleLevel { ... } { ... }`:
In Alloy, you can write constraints directly in the signature:
```alloy
sig DeductibleLevel {
    product: one Product,
    coverages: Coverage -> RiskType -> DeductibleValue
}
```
If we use a `fact` block:
```alloy
fact {
    all dl: DeductibleLevel, c: dl.product.base_coverages, r: RiskType |
        one dl.coverages[c][r]

    all dl: DeductibleLevel |
        dl.coverages.DeductibleValue = (dl.product.base_coverages + dl.product.optional_coverages) <: risk_types
}
```
Wait! Let's examine:
If `dl.coverages.DeductibleValue = (dl.product.base_coverages + dl.product.optional_coverages) <: risk_types`,
and `all dl: DeductibleLevel, c: dl.product.base_coverages, r: RiskType | one dl.coverages[c][r]`.
Wait, if `c in dl.product.base_coverages` and `r in RiskType`,
then `one dl.coverages[c][r]` implies `some dl.coverages[c][r]`.
Which means `(c, r) in dl.coverages.DeductibleValue`.
Which means `(c, r) in (dl.product.base_coverages + dl.product.optional_coverages) <: risk_types`.
Which means `r in c.risk_types`.
So for any base coverage of a deductible level, its `risk_types` must contain all `RiskType`s!
Wait, is that what the