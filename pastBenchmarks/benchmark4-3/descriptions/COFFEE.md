There are disjoint sets called "Thing", "Property", "QuallitativeState", and "Process".

Every "Thing" is related to exactly one "Thing" in a relation called 
"touches". Every "Thing" is related to zero or more "Property" elements through a relation called "hasProperty".

Every "Property" has an "influences" relation connecting it to zero or more "Property" elements. Every "Property" is related to exactly one "QuallitativeState" called its "state".

"QuallitativeState" consists of exactly the distinct elements "INCREASING", "DECREASING", and "NOCHANGE".

All "Thing"s are "ThermalThing"s.  There is exactly one "Substance" and exactly one "Cup", and each of them is a distinct "ThermalThing". There are no other "ThermalThing"s. There is exactly one "Coffee", which is the only "Substance".

The set "ThermalProperty" is equal to the set "Property".

The disjoint sets "HEAT" and "TEMPERATURE" are subsets of "ThermalProperty".

There are exactly one "TEMPERATURE_OF_COFFEE" and exactly one "TEMPERATURE_OF_CUP", and each of them is distinct element of the set "TEMPERATURE".  There are no other elements of "TEMPERATURE".

There are exactly one "HEAT_OF_COFFEE" and exactly one "HEAT_OF_CUP", and each of them is a "HEAT". There are no other elements of "HEAT".

Every "Process" is associated with exactly one "increases" "HEAT" and with exactly one "decreases" "HEAT".

There is exactly one "HeatFlow", and it is a "Process".  There are no other elements in "HeatFlow".

Every "HEAT" has a "greaterThan" relation to at most one "HEAT".

The "greaterThan" relation never relates any "HEAT" to itself.
The "greaterThan" relation is not equal to its converse.

The "touches" relation never relates any "Thing" to itself.
The "touches" relation is symmetric.

"Coffee" "hasProperty" "TEMPERATURE_OF_COFFEE" and also "HEAT_OF_COFFEE".  "Cup" has the same properties.  Nothing else has properties.

"HEAT_OF_COFFEE" influences "TEMPERATURE_OF_COFFEE", and "HEAT_OF_CUP" influences "TEMPERATURE_OF_CUP".  There are no other influences.

// NAD: this seems to be impossible b/c there must be a "HeatFlow" element 
If a "ThermalThing" "touches" neither "Cup" nor "Coffee", then there is no "greaterThan" relationship at all and there is no "HeatFlow".

A "ThermalThing" "touches" "Cup" or "Coffee" if and only if one of these three conditions holds:  
(1) "HEAT_OF_COFFEE" is "greaterThan" "HEAT_OF_CUP", 
or 
(2) "HEAT_OF_CUP" is "greaterThan" "HEAT_OF_COFFEE", 
or
(3) neither "HEAT_OF_CUP" nor "HEAT_OF_COFFEE" is "greaterThan" the other.

If a "ThermalThing" 
"touches" either "Cup" or "Coffee"
and 
neither "HEAT_OF_CUP" nor "HEAT_OF_COFFEE" is "greaterThan" the other 
then 
the "HeatFlow" does not "increases" the "HEAT_OF_CUP", 
the "HeatFlow" does not "increases" the "HEAT_OF_COFFEE",  
the "HeatFlow" does not "decreases" "HEAT_OF_COFFEE", and
the "HeatFlow" does not "decreases" "HEAT_OF_CUP".

Additionally, if a "ThermalThing" 
"touches" either "Cup" or "Coffee" 
when 
"HEAT_OF_CUP" is "greaterThan" "HEAT_OF_COFFEE" 
then
the "state" of "HEAT_OF_COFFEE" must be "INCREASING",
the "state" of "TEMPERATURE_OF_COFFEE" must be "INCREASING",
the "state" of "HEAT_OF_CUP" must be "DECREASING",
and "state" of "TEMPERATURE_OF_CUP" must be "DECREASING", 
only "HeatFlow" "increases" "HEAT_OF_COFFEE", and 
only "HeatFlow" "decreases" "HEAT_OF_CUP".

However, if a "ThermalThing" 
"touches" either "Cup" or "Coffee" 
when "HEAT_OF_COFFEE" is "greaterThan" "HEAT_OF_CUP" 
then
the "state" of "HEAT_OF_COFFEE" must be "DECREASING",
the "state" of "TEMPERATURE_OF_COFFEE" must be "DECREASING",
the "state" of "HEAT_OF_CUP" must be "INCREASING",
and "state" of "TEMPERATURE_OF_CUP" must be "INCREASING",
only "HeatFlow" "increases" "HEAT_OF_CUP", and 
only "HeatFlow" decreases "HEAT_OF_COFFEE".
