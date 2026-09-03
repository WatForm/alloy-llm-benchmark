sig RiskType {}

sig DeductibleValue {}

sig Coverage {
  risk_types: set RiskType
}

sig Product {
  base_coverages: set Coverage,
  optional_coverages: set Coverage,
  risk_types: set RiskType
}

sig DeductibleLevel {
  product: one Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

fact {
  all d: DeductibleLevel |
    all c: d.product.base_coverages, r: RiskType |
      one d.coverages[c][r]
}

fact {
  all d: DeductibleLevel |
    { c: Coverage, r: RiskType |
      some d.coverages[c][r]
    } =
    { c: Coverage, r: RiskType |
      c in d.product.base_coverages + d.product.optional_coverages
      and r in c.risk_types
    }
}