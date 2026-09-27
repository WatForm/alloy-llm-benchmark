Wait, in Alloy, can you write:
  `{ c: Coverage, r: RiskType | (c in dl.product.base_coverages + dl.product.optional_coverages) and (r in c.risk_types) }`?
  YES! That is valid syntax in Alloy!
  Wait, what about:
  `all dl: DeductibleLevel, c: Coverage, r: RiskType | ...`?
  Wait, does `{ c: Coverage, r: RiskType | ... }` equal `dl.coverages.DeductibleValue`?
  Yes, `dl.coverages.DeductibleValue` is a relation of type `Coverage -> RiskType`.
  The comprehension `{ c: Coverage, r: RiskType | ... }` is also a relation of type `Coverage -> RiskType`.
  Setting them equal:
  `dl.coverages.DeductibleValue = { c: Coverage, r: RiskType | (c in dl.product.base_coverages + dl.product.optional_coverages) and (r in c.risk_types) }`
  Wait, is this identical to:
  `all dl: DeductibleLevel, c: Coverage, r: RiskType | c->r in dl.coverages.DeductibleValue iff ((c in dl.product.base_coverages + dl.product.optional_coverages) and (r in c.risk_types))`?
  Yes, by extensionality, two sets of pairs are equal iff they contain the exact same elements!

  Wait, let's think: is there any difference between:
  `some dl.coverages[c][r]` and `c->r in dl.coverages.DeductibleValue`?
  Let's verify:
  `dl.coverages` is a subset of `Coverage -> RiskType -> DeductibleValue`.
  In Alloy:
  `c->r in dl.coverages.DeductibleValue`
  means:
  `some v: DeductibleValue | c->r->v in dl.coverages`.
  And `dl.coverages[c][r]` is:
  `r.(c.(dl.coverages))`, which is:
  `{ v: DeductibleValue | c->r->v in dl.coverages }`.
  So `some dl.coverages[c][r]` means there is at least one `v in DeductibleValue` such that `c->r->v in dl.coverages`.
  Thus, `c->r in dl.coverages.DeductibleValue` is EXACTLY `some dl.coverages[c][r]`!

  Wait! Let's check: what about Sentence 5?
  "There is exactly one "DeductibleValue" for every combination of one of the "DeductibleLevel"'s "product"'s "base_coverages" and