There are disjoint sets called "Thing", "Property", "QuallitativeState", and "Process".

Every "Thing" is related to exactly one "Thing" by "touches" and to zero or more "Property" elements by "hasProperty". Every "Property" relates by "influences" to zero or more "Property" elements and has exactly one "QuallitativeState" as its "state".

"QuallitativeState" consists exactly of the distinct elements "INCREASING", "DECREASING", and "NOCHANGE".

Every "Thing" is a "ThermalThing". There is exactly one "Substance" and exactly one "Cup"; they are distinct "ThermalThing" elements. There is exactly one "Coffee", which is the only "Substance". The remaining constraints imply that there are no other "ThermalThing" elements.

Every "Property" is a "ThermalProperty". The sets "HEAT" and "TEMPERATURE" are disjoint subsets of "ThermalProperty". "TEMPERATURE_OF_COFFEE" and "TEMPERATURE_OF_CUP" are distinct, individually named elements of "TEMPERATURE". "HEAT_OF_COFFEE" and "HEAT_OF_CUP" are distinct, individually named elements of "HEAT". These names do not, by themselves, exclude additional elements of either set.

Every "Process" has exactly one "HEAT" element through "increases" and exactly one through "decreases". "HeatFlow" is the only "Process".

Each "HEAT" element relates through "greaterThan" to at most one "HEAT" element. "greaterThan" has no self-links and differs from its converse.

"touches" has no self-links and is symmetric.

The complete "hasProperty" relation consists of "Coffee" linked to "TEMPERATURE_OF_COFFEE" and "HEAT_OF_COFFEE", and "Cup" linked to "TEMPERATURE_OF_CUP" and "HEAT_OF_CUP". The complete "influences" relation consists of "HEAT_OF_COFFEE" linked to "TEMPERATURE_OF_COFFEE", and "HEAT_OF_CUP" linked to "TEMPERATURE_OF_CUP".

If any "ThermalThing" touches neither "Cup" nor "Coffee", then "greaterThan" has no links and "HeatFlow" is absent.

For each "ThermalThing", its "touches" target is "Cup" or "Coffee" if and only if at least one of the following holds: "greaterThan" consists exactly of the link from "HEAT_OF_COFFEE" to "HEAT_OF_CUP"; "greaterThan" consists exactly of the reverse link; or the entire "greaterThan" relation differs from the relation containing both of those links.

If a "ThermalThing" touches "Cup" or "Coffee" and the entire "greaterThan" relation differs from the relation containing both named links, then the complete "increases" relation differs from the relation linking "HeatFlow" to both named "HEAT" elements, and the complete "decreases" relation also differs from that two-link relation. This does not forbid either individual link.

If a "ThermalThing" touches "Cup" or "Coffee" and "greaterThan" consists exactly of the link from "HEAT_OF_CUP" to "HEAT_OF_COFFEE", then the complete "state" relation assigns "INCREASING" to "HEAT_OF_COFFEE" and "TEMPERATURE_OF_COFFEE", and "DECREASING" to "HEAT_OF_CUP" and "TEMPERATURE_OF_CUP". In that case, "increases" consists exactly of "HeatFlow" linked to "HEAT_OF_COFFEE", and "decreases" consists exactly of "HeatFlow" linked to "HEAT_OF_CUP".

If a "ThermalThing" touches "Cup" or "Coffee" and "greaterThan" consists exactly of the link from "HEAT_OF_COFFEE" to "HEAT_OF_CUP", then the complete "state" relation assigns "DECREASING" to "HEAT_OF_COFFEE" and "TEMPERATURE_OF_COFFEE", and "INCREASING" to "HEAT_OF_CUP" and "TEMPERATURE_OF_CUP". In that case, "decreases" consists exactly of "HeatFlow" linked to "HEAT_OF_COFFEE", and "increases" consists exactly of "HeatFlow" linked to "HEAT_OF_CUP".
