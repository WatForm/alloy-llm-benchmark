There are five distinct kinds of elements: "DeductibleLevel", "Product", "Coverage", "RiskType", and "DeductibleValue".

Each "DeductibleLevel" has exactly one "product", which is a "Product".  
Each "DeductibleLevel" also has a relation called "coverages" from "Coverage" and "RiskType" to "DeductibleValue". 

Each "Product" has a set of "base_coverages", which consist of elements of "Coverage", a set of "optional_coverages", which consist of elements of "Coverage", and a set of "risk_types", which consist of elements of "RiskType".

Each "Coverage" has a set of "risk_types", which consist of elements of "RiskType".

The coverages means exactly the set of "base_coverages" plus "optional_coverages".

There is exactly one "DeductibleValue" for every combination of one of the "DeductibleLevel"'s "product"'s "base_coverages" and any "RiskType".

The set of pairs consisting of a "Coverage" and a "RiskType" that appear in a "DeductibleLevel"'s "coverages" relation is exactly the set of pairs where:
  - the "Coverage" belongs to the "coverages" of that "DeductibleLevel"'s "product", and
  - the "RiskType" belongs to the "risk_types" of that "Coverage".

