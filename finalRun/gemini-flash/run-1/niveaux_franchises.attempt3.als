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
    all dl: DeductibleLevel, c: dl.product.base_coverages, rt: RiskType |
        one dl.coverages[c][rt]

    all dl: DeductibleLevel |
        dl.coverages.DeductibleValue = { c: Coverage, rt: RiskType |
            c in (dl.product.base_coverages + dl.product.optional_coverages) and
            rt in c.risk_types
        }
}