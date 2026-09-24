sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

enum QuallitativeState { INCREASING, DECREASING, NOCHANGE }

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing in Thing {}
fact { Thing in ThermalThing }

one sig Substance in ThermalThing {}
one sig Cup in ThermalThing {}
fact { no Substance & Cup }
fact { ThermalThing = Substance + Cup }

one sig Coffee in Substance {}
fact { Substance = Coffee }

sig ThermalProperty in Property {}
fact { ThermalProperty = Property }

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}
sig TEMPERATURE in ThermalProperty {}
fact { no HEAT & TEMPERATURE }

one sig TEMPERATURE_OF_COFFEE in TEMPERATURE {}
one sig TEMPERATURE_OF_CUP in TEMPERATURE {}
fact { no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP }
fact { TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP }

one sig HEAT_OF_COFFEE in HEAT {}
one sig HEAT_OF_CUP in HEAT {}
fact { no HEAT_OF_COFFEE & HEAT_OF_CUP }
fact { HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP }

one sig HeatFlow in Process {}
fact { Process = HeatFlow }

fact {
  no iden & greaterThan
  greaterThan != ~greaterThan
}

fact {
  no iden & touches
  touches = ~touches
}

fact {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  no (Thing - Coffee - Cup).hasProperty
}

fact {
  influences = HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE + HEAT_OF_CUP -> TEMPERATURE_OF_CUP
}

fact {
  all t: ThermalThing | (Cup not in t.touches and Coffee not in t.touches) implies (no greaterThan and no HeatFlow)
}

fact {
  all t: ThermalThing |
    (Cup in t.touches or Coffee in t.touches) iff
    (
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan or
      HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan or
      (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan)
    )
}

fact {
  all t: ThermalThing |
    ( (Cup in t.touches or Coffee in t.touches) and
      (HEAT_OF_CUP not in HEAT_OF_COFFEE.greaterThan and HEAT_OF_COFFEE not in HEAT_OF_CUP.greaterThan) ) implies
    (
      HEAT_OF_CUP not in HeatFlow.increases and
      HEAT_OF_COFFEE not in HeatFlow.increases and
      HEAT_OF_COFFEE not in HeatFlow.decreases and
      HEAT_OF_CUP not in HeatFlow.decreases
    )
}

fact {
  all t: ThermalThing |
    ( (Cup in t.touches or Coffee in t.touches) and
      HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan ) implies
    (
      HEAT_OF_COFFEE.state = INCREASING and
      TEMPERATURE_OF_COFFEE.state = INCREASING and
      HEAT_OF_CUP.state = DECREASING and
      TEMPERATURE_OF_CUP.state = DECREASING and
      increases.HEAT_OF_COFFEE = HeatFlow and
      decreases.HEAT_OF_CUP = HeatFlow
    )
}

fact {
  all t: ThermalThing |
    ( (Cup in t.touches or Coffee in t.touches) and
      HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan ) implies
    (
      HEAT_OF_COFFEE.state = DECREASING and
      TEMPERATURE_OF_COFFEE.state = DECREASING and
      HEAT_OF_CUP.state = INCREASING and
      TEMPERATURE_OF_CUP.state = INCREASING and
      increases.HEAT_OF_CUP = HeatFlow and
      decreases.HEAT_OF_COFFEE = HeatFlow
    )
}