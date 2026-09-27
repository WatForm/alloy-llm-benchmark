sig Coverage {
  risk_types: set RiskType
}

sig RiskType {}

sig DeductibleValue {}

sig Product {
  base_coverages: set Coverage,
  optional_coverages: set Coverage,
  risk_types: set RiskType
}

sig DeductibleLevel {
  product: one Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

fact DeductibleLevelCoverages {
  all d: DeductibleLevel, c: Coverage, r: RiskType |
    ((c in d.product.base_coverages or c in d.product.optional_coverages)
      and r in c.risk_types)
    iff one d.coverages[c][r]
}