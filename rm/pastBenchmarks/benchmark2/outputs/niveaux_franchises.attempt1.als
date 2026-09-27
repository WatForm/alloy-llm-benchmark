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

fun coverages[p: Product]: set Coverage {
  p.base_coverages + p.optional_coverages
}

sig DeductibleLevel {
  product: one Product,
  coverages: Coverage -> RiskType -> DeductibleValue
}

pred is_valid[dl: DeductibleLevel] {
  dl.coverages.DeductibleValue = ((coverages[dl.product]) <: risk_types)
  all c: dl.product.base_coverages, r: c.risk_types | one dl.coverages[c][r]
}

fact AllDeductibleLevelsAreValid {
  all dl: DeductibleLevel | is_valid[dl]
}