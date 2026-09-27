sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig QuallitativeState {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

fact QuallitativeStateElements {
  QuallitativeState = INCREASING + DECREASING + NOCHANGE
}

sig ThermalThing in Thing {}

fact AllThingsThermal {
  Thing = ThermalThing
}

one sig Cup in ThermalThing {}
one sig Substance in ThermalThing {}
one sig Coffee in Substance {}

fact ThermalThingStructure {
  Cup != Substance
  Substance = Coffee
}

sig ThermalProperty in Property {}

fact AllPropertiesThermal {
  Property = ThermalProperty
}

sig HEAT extends Property {
  greaterThan: lone HEAT
}

sig TEMPERATURE extends Property {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE {}

lone sig HeatFlow extends Process {}

fact HeatFlowOnlyProcess {
  Process = HeatFlow
}

fact TouchesConstraints {
  all t: Thing | t not in t.touches
  all t1, t2: Thing | (t1->t2 in touches) implies (t2->t1 in touches)
}

fact GreaterThanConstraints {
  all h: HEAT | h not in h.greaterThan
  all h1, h2: HEAT | (h1->h2 in greaterThan) implies (h2->h1 not in greaterThan)
}

fact HasPropertyRelation {
  hasProperty = (Coffee->TEMPERATURE_OF_COFFEE) + (Coffee->HEAT_OF_COFFEE)
              + (Cup->TEMPERATURE_OF_CUP) + (Cup->HEAT_OF_CUP)
}

fact InfluencesRelation {
  influences = (HEAT_OF_COFFEE->TEMPERATURE_OF_COFFEE)
             + (HEAT_OF_CUP->TEMPERATURE_OF_CUP)
}

fact NoTouchNoHeatFlow {
  (some t: ThermalThing | t.touches not in Cup + Coffee)
    implies (no greaterThan and no HeatFlow)
}

fact TouchesIffGreaterThan {
  all t: ThermalThing |
    (t.touches in Cup + Coffee) iff
      ((greaterThan = (HEAT_OF_COFFEE->HEAT_OF_CUP))
        or (greaterThan = (HEAT_OF_CUP->HEAT_OF_COFFEE))
        or (greaterThan != (HEAT_OF_COFFEE->HEAT_OF_CUP) + (HEAT_OF_CUP->HEAT_OF_COFFEE)))
}

fact TouchAndDifferentGreaterThan {
  all t: ThermalThing |
    ((t.touches in Cup + Coffee) and
      (greaterThan != (HEAT_OF_COFFEE->HEAT_OF_CUP) + (HEAT_OF_CUP->HEAT_OF_COFFEE)))
    implies
      ((increases != (HeatFlow->HEAT_OF_COFFEE) + (HeatFlow->HEAT_OF_CUP))
        and (decreases != (HeatFlow->HEAT_OF_COFFEE) + (HeatFlow->HEAT_OF_CUP)))
}

fact GreaterThanCupToCoffee {
  all t: ThermalThing |
    ((t.touches in Cup + Coffee) and
      (greaterThan = (HEAT_OF_CUP->HEAT_OF_COFFEE)))
    implies
      ((state = (HEAT_OF_COFFEE->INCREASING) + (TEMPERATURE_OF_COFFEE->INCREASING)
              + (HEAT_OF_CUP->DECREASING) + (TEMPERATURE_OF_CUP->DECREASING))
        and (increases = (HeatFlow->HEAT_OF_COFFEE))
        and (decreases = (HeatFlow->HEAT_OF_CUP)))
}

fact GreaterThanCoffeeToCup {
  all t: ThermalThing |
    ((t.touches in Cup + Coffee) and
      (greaterThan = (HEAT_OF_COFFEE->HEAT_OF_CUP)))
    implies
      ((state = (HEAT_OF_COFFEE->DECREASING) + (TEMPERATURE_OF_COFFEE->DECREASING)
              + (HEAT_OF_CUP->INCREASING) + (TEMPERATURE_OF_CUP->INCREASING))
        and (decreases = (HeatFlow->HEAT_OF_COFFEE))
        and (increases = (HeatFlow->HEAT_OF_CUP)))
}