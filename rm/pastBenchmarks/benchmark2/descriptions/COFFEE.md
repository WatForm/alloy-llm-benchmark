The model consists of abstract signatures, namely "Thing", "Property", and "QuallitativeState". "Substance", "Cup", and "Coffee" are the concrete signatures extending "ThermalThing", which extends "Thing". We also have "HEAT", "ThermalProperty" and "TEMPERATURE" that extend the signature "Property".

There are fields associated with the signatures. The "Thing" signature has a field named "touches" with exactly one "Thing" and another field "hasProperty" with a set of "Property". The "Property" signature has a field "influences" that carries a set of "Property", and another field "state" with exactly one "QualitativeState". 

The signature "HEAT" has a field "greaterThan" with at most one "HEAT". The "QuallitativeState" signature is the parent of three singletons: "INCREASING", "DECREASING" and "NOCHANGE". 

The signature "Process" has two fields: "increases" has exactly one "HEAT" and decreases also has exactly one "HEAT". Two singleton signatures extending "HEAT", namely "HEAT_OF_COFFEE" and "HEAT_OF_CUP", are defined in the model. A singleton named "HeatFlow", extending the "Process", is also present in the model.

Several constraints exist in the model:

- No "greaterThan" can be related to itself via an identity relation.
- "greaterThan" is not equal to its transpose relation.
- No "Thing" via "touches" can be related to itself via an identity relation.
- The "touches" relation equals the transpose of "touches".
- The "Thing" related to "hasProperty" consists of "Coffee" and the union of "TEMPERATURE_OF_COFFEE" and "HEAT_OF_COFFEE", as well as the "Cup" and the union of "TEMPERATURE_OF_CUP" and "HEAT_OF_CUP".
- The "Property" related to "influences" relation is equal to the combination of "HEAT_OF_COFFEE" implying "TEMPERATURE_OF_COFFEE" and "HEAT_OF_CUP" implying "TEMPERATURE_OF_CUP".

It also offers conditions for checking "ThermalThings" that are not touching either the "Cup" or "Coffee", "ThermalThings" that are touching either the "Cup" or "Coffee", and special cases where "ThermalThings" touching either the "Cup" or "Coffee" have a "greaterThan" relation with "HEAT_OF_CUP" implying "HEAT_OF_COFFEE" or vice versa. There are specific changes in state, increase or decrease with the presence of "HeatFlow", depending on the presence of "greaterThan" relations.