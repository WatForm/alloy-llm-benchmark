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
  all d: DeductibleLevel, c: d.product.base_coverages, r: c.risk_types |
    one d.coverages[c][r]
}

fact {
  all d: DeductibleLevel, c: Coverage, r: RiskType |
    (some d.coverages[c][r]) <=> 
    (c in d.product.base_coverages + d.product.optional_coverages and r in c.risk_types)
}