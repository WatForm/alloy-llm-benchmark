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

fun coverages [p: Product]: set Coverage {
  p.base_coverages + p.optional_coverages
}

fact allBaseCoveragesHaveValues {
  all d: DeductibleLevel, c: d.product.base_coverages, r: RiskType |
    one d.coverages[c][r]
}

fact coveragesDomain {
  all d: DeductibleLevel |
    d.coverages.DeductibleValue =
      { c: Coverage, r: RiskType | c in coverages[d.product] and r in c.risk_types }
}