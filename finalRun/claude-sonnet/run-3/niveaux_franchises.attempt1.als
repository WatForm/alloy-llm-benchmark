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

sig DeductibleLevel {
    product: one Product,
    coverages: Coverage -> RiskType -> DeductibleValue
}

fact {
    all dl: DeductibleLevel |
        all c: dl.product.base_coverages, r: RiskType |
            one dv: DeductibleValue | dv in c.(r.(dl.coverages))
}

fact {
    all dl: DeductibleLevel |
        all c: Coverage, r: RiskType |
            (some dl.coverages[c][r]) <=>
                (c in (dl.product.base_coverages + dl.product.optional_coverages) and r in c.risk_types)
}