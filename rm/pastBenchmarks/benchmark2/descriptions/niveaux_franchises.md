This model consists of several entities:

- A "Product" has a set of "base_coverages" and a set of "optional_coverages", both consisting of "Coverage" entities. It also has a set of "risk_types". In addition, a function "coverages" is defined which unifies "base_coverages" and "optional_coverages" for a specific "Product", yielding a set of "Coverage" entities.
  
- A "Coverage" comprises a set of "RiskType".

- "RiskType" is a simple entity with no further specification.

- "DeductibleValue" is a simple entity with no further specification.

The entity "DeductibleLevel" describes a specific product with a dedicated relation named "product" to a "Product" entity, and a ternary relation "coverages" that connects a "Coverage", "RiskType", and "DeductibleValue".

A predicate "DeductibleLevel.is_valid" is defined, with two constraints: 
Firstly, the "Coverage" and "RiskType" pairs selected from the "coverages" of a "DeductibleLevel" must match with the pairs obtained by taking the "coverages" of the specific "Product" and mapping them to "risk_types". Secondly, for every "Coverage" in the "base_coverages" of the "Product" of this "DeductibleLevel" and every "RiskType", there exists exactly one "DeductibleValue" in the "coverages" of this "DeductibleLevel".

A fact named "AllDeductibleLevelsAreValid" is defined, which asserts that for every "DeductibleLevel" instance, the predicate "DeductibleLevel.is_valid" must hold true.
It means every "DeductibleLevel" must satisfy the conditions laid out in the "is_valid" predicate.