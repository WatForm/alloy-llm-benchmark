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
    all dl: DeductibleLevel |
        all c: Coverage |
            (some dl.coverages[c]) iff
                c in (dl.product.base_coverages + dl.product.optional_coverages)

    all dl: DeductibleLevel |
        all c: Coverage |
            all r: RiskType |
                (some dl.coverages[c][r]) iff
                    (c in (dl.product.base_coverages + dl.product.optional_coverages)
                        and r in c.risk_types)

    all dl: DeductibleLevel |
        all c: dl.product.base_coverages |
            all r: RiskType |
                one dl.coverages[c][r]
}