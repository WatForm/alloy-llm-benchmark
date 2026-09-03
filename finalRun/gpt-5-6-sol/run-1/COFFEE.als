abstract sig QuallitativeState {}

one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig ThermalProperty in Property {}

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}

sig TEMPERATURE in ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP in TEMPERATURE {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP in HEAT {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

one sig HeatFlow in Process {}

sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig ThermalThing in Thing {}

one sig Substance in ThermalThing {}

one sig Cup in ThermalThing {}

one sig Coffee in Substance {}

fact {
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  no Substance & Cup
  Substance = Coffee

  ThermalProperty = Property
  no HEAT & TEMPERATURE

  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP

  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

  Process = HeatFlow
}

fact {
  no iden & greaterThan
  greaterThan != ~greaterThan

  no iden & touches
  touches = ~touches
}

fact {
  hasProperty =
    (Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)) +
    (Cup -> (TEMPERATURE_OF_CUP + HEAT_OF_CUP))

  influences =
    (HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE) +
    (HEAT_OF_CUP -> TEMPERATURE_OF_CUP)
}

fact {
  all t: ThermalThing |
    no (t.touches & (Cup + Coffee)) implies {
      no greaterThan
      no HeatFlow
    }
}

fact {
  all t: ThermalThing |
    some (t.touches & (Cup + Coffee)) iff {
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
      or HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
      or {
        HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
        HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
      }
    }
}

fact {
  all t: ThermalThing |
    {
      some (t.touches & (Cup + Coffee))
      HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan
      HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan
    } implies {
      HEAT_OF_CUP not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.decreases
      HEAT_OF_CUP not in HeatFlow.decreases
    }
}

fact {
  all t: ThermalThing |
    {
      some (t.touches & (Cup + Coffee))
      HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
    } implies {
      HEAT_OF_COFFEE.state = INCREASING
      TEMPERATURE_OF_COFFEE.state = INCREASING
      HEAT_OF_CUP.state = DECREASING
      TEMPERATURE_OF_CUP.state = DECREASING
      increases.HEAT_OF_COFFEE = HeatFlow
      decreases.HEAT_OF_CUP = HeatFlow
    }
}

fact {
  all t: ThermalThing |
    {
      some (t.touches & (Cup + Coffee))
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
    } implies {
      HEAT_OF_COFFEE.state = DECREASING
      TEMPERATURE_OF_COFFEE.state = DECREASING
      HEAT_OF_CUP.state = INCREASING
      TEMPERATURE_OF_CUP.state = INCREASING
      increases.HEAT_OF_CUP = HeatFlow
      decreases.HEAT_OF_COFFEE = HeatFlow
    }
}