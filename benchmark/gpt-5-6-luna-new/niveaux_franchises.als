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
    all d: DeductibleLevel |
        all c: d.product.base_coverages, r: RiskType |
            one d.coverages[c][r]

    all d: DeductibleLevel |
        all c: Coverage, r: RiskType |
            (some d.coverages[c][r]) iff
            (c in d.product.base_coverages + d.product.optional_coverages
             and r in c.risk_types)
}