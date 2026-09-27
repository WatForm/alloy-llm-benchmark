sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

fact QuallitativeStatePartition {
  QuallitativeState = INCREASING + DECREASING + NOCHANGE
}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing in Thing {}

one sig Substance in ThermalThing {}
one sig Cup in ThermalThing {}

fact ThermalThingFacts {
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  Substance != Cup
}

one sig Coffee in Substance {}

fact CoffeeFact {
  Substance = Coffee
}

sig ThermalProperty in Property {}

fact ThermalPropertyFact {
  ThermalProperty = Property
}

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

fact HeatTemperatureDisjoint {
  no (HEAT & TEMPERATURE)
}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP in TEMPERATURE {}

fact TemperatureFacts {
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  TEMPERATURE_OF_COFFEE != TEMPERATURE_OF_CUP
}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP in HEAT {}

fact HeatFacts {
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP
  HEAT_OF_COFFEE != HEAT_OF_CUP
}

one sig HeatFlow in Process {}

fact HeatFlowFact {
  Process = HeatFlow
}

fact GreaterThanFacts {
  no (iden & greaterThan)
  greaterThan != ~greaterThan
}

fact TouchesFacts {
  no (iden & touches)
  touches = ~touches
}

fact HasPropertyFacts {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  all t: Thing | (t != Coffee and t != Cup) implies no t.hasProperty
}

fact InfluencesFacts {
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
  all p: Property | (p != HEAT_OF_COFFEE and p != HEAT_OF_CUP) implies no p.influences
}

fact TouchesNeitherFact {
  (some t: ThermalThing | no (t.touches & (Cup + Coffee)))
  implies
  (no greaterThan and no HeatFlow)
}

fact TouchesIffFact {
  all t: ThermalThing |
    (t.touches in (Cup + Coffee)) iff (
      HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan
      or HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan
      or (HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan and HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan)
    )
}

fact NoChangeFact {
  (some t: ThermalThing | t.touches in (Cup + Coffee))
  and
  (HEAT_OF_CUP -> HEAT_OF_COFFEE not in greaterThan and HEAT_OF_COFFEE -> HEAT_OF_CUP not in greaterThan)
  implies
  (
    HeatFlow.increases != HEAT_OF_CUP and
    HeatFlow.increases != HEAT_OF_COFFEE and
    HeatFlow.decreases != HEAT_OF_COFFEE and
    HeatFlow.decreases != HEAT_OF_CUP
  )
}

fact CupGreaterFact {
  (some t: ThermalThing | t.touches in (Cup + Coffee))
  and
  (HEAT_OF_CUP -> HEAT_OF_COFFEE in greaterThan)
  implies
  (
    HEAT_OF_COFFEE.state = INCREASING and
    TEMPERATURE_OF_COFFEE.state = INCREASING and
    HEAT_OF_CUP.state = DECREASING and
    TEMPERATURE_OF_CUP.state = DECREASING and
    (all p: Process | p.increases = HEAT_OF_COFFEE implies p = HeatFlow) and
    (all p: Process | p.decreases = HEAT_OF_CUP implies p = HeatFlow)
  )
}

fact CoffeeGreaterFact {
  (some t: ThermalThing | t.touches in (Cup + Coffee))
  and
  (HEAT_OF_COFFEE -> HEAT_OF_CUP in greaterThan)
  implies
  (
    HEAT_OF_COFFEE.state = DECREASING and
    TEMPERATURE_OF_COFFEE.state = DECREASING and
    HEAT_OF_CUP.state = INCREASING and
    TEMPERATURE_OF_CUP.state = INCREASING and
    (all p: Process | p.increases = HEAT_OF_CUP implies p = HeatFlow) and
    (all p: Process | p.decreases = HEAT_OF_COFFEE implies p = HeatFlow)
  )
}