sig DeductibleLevel {
  product: one Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

sig Product {
  base_coverages: set Coverage,
  optional_coverages: set Coverage,
  risk_types: set RiskType
}

sig Coverage {
  risk_types: set RiskType
}

sig RiskType {}

sig DeductibleValue {}

fact {
  all dl: DeductibleLevel | {
    all c: dl.product.base_coverages, r: c.risk_types |
      one r.(c.(dl.coverages))

    dl.coverages.DeductibleValue = {
      c: Coverage, r: RiskType |
        c in (dl.product.base_coverages + dl.product.optional_coverages) and
        r in c.risk_types
    }
  }
}