TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
Cup.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
all t: Thing - Coffee - Cup | no t.hasProperty
```
Or simply:
```alloy
Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
Cup.hasProperty = Coffee.hasProperty
no (Thing - Coffee - Cup).hasProperty
```
That directly captures every part of:
`"Coffee" "hasProperty" "TEMPERATURE_OF_COFFEE" and also "HEAT_OF_COFFEE". "Cup" has the same properties. Nothing else has properties.`!

Wait, let's also check:
Could `hasProperty` also include `TEMPERATURE_OF_CUP` if someone wrote:
Wait, what if the original author of the Alloy model DID write:
`Cup.hasProperty = Coffee.hasProperty`?
Why would they write that?
Because in qualitative modeling, maybe they modeled `Coffee` and `Cup` sharing properties, or it was a bug in the model that Nancy Day was checking!
Remember: Nancy Day's research was on finding bugs or analyzing Alloy models!

Now let's check the rest of the description very carefully:

1.
"There are disjoint sets called "Thing", "Property", "QuallitativeState", and "Process"."

How to define them in Alloy?
In Alloy, top-level signatures without `extends` or `in` are disjoint by default!
```alloy
abstract sig Thing {
    touches: one Thing,
    hasProperty: set Property
}

abstract sig Property {
    influences: set Property,
    state: one QuallitativeState
}

enum QuallitativeState {
    INCREASING,
    DECREASING,
    NOCHANGE
}

abstract sig Process {
    increases: one HEAT,
    decreases: one HEAT
}
```
Wait! Are `Thing`, `Property`, `QuallitativeState`, and `Process` disjoint?
Yes! In Alloy, different top-level sigs are mutually disjoint.

Wait, what about:
`"QuallitativeState" consists of exactly the distinct elements "INCREASING", "DECREASING", and "NOCHANGE".`
With `enum QuallitativeState { INCREASING, DECREASING, NOCHANGE }`, it consists of exactly those three distinct elements.

2.
"All "Thing"s are "ThermalThing"s. There is exactly one "Substance" and exactly one "Cup", and each of them is a distinct "ThermalThing". There are no other "ThermalThing"s. There is exactly one "Coffee", which is the only "Substance"."

Let's look at the signatures:
```alloy
abstract sig ThermalThing extends Thing {}

abstract sig Substance extends ThermalThing {}

one sig Coffee extends Substance {}

one sig Cup extends ThermalThing {}
```
Wait, let's check:
- `