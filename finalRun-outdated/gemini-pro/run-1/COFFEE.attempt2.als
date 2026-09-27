sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

abstract sig QuallitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

sig ThermalThing in Thing {}
fact { Thing in ThermalThing }

one sig Substance in ThermalThing {}
one sig Cup in ThermalThing {}
fact { no Substance & Cup }
fact { ThermalThing in Substance + Cup }

one sig Coffee in Substance {}
fact { Substance in Coffee }

sig ThermalProperty in Property {}
fact { ThermalProperty = Property }

sig HEAT in ThermalProperty {
  greaterThan: lone HEAT
}
sig TEMPERATURE in ThermalProperty {}
fact { no HEAT & TEMPERATURE }

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP in TEMPERATURE {}
fact { no TEMPERATURE_OF_COFFEE & TEMPERATURE_OF_CUP }
fact { TEMPERATURE in TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP }

one sig HEAT_OF_COFFEE, HEAT_OF_CUP in HEAT {}
fact { no HEAT_OF_COFFEE & HEAT_OF_CUP }
fact { HEAT in HEAT_OF_COFFEE + HEAT_OF_CUP }

one sig HeatFlow in Process {}
fact { Process in HeatFlow }

fact {
  no h: HEAT | h in h.greaterThan
}

fact {
  greaterThan != ~greaterThan
}

fact {
  no t: Thing | t in t.touches
}

fact {
  touches = ~touches
}

fact {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
  no (Thing - Coffee - Cup).hasProperty
}

fact {
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
  no (Property - HEAT_OF_COFFEE - HEAT_OF_CUP).influences
}

fact {
  all t: ThermalThing | 
    (not (Cup in t.touches) and not (Coffee in t.touches)) implies (no greaterThan and no HeatFlow)
}

fact {
  all t: ThermalThing | 
    (Cup in t.touches or Coffee in t.touches) iff 
    (
      (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) or 
      (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan) or 
      (not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) and not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan))
    )
}

fact {
  all t: ThermalThing | 
    (
      (Cup in t.touches or Coffee in t.touches) and 
      (not (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan) and not (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan))
    ) implies (
      not (HEAT_OF_CUP in HeatFlow.increases) and 
      not (HEAT_OF_COFFEE in HeatFlow.increases) and 
      not (HEAT_OF_COFFEE in HeatFlow.decreases) and 
      not (HEAT_OF_CUP in HeatFlow.decreases)
    )
}

fact {
  all t: ThermalThing | 
    (
      (Cup in t.touches or Coffee in t.touches) and 
      (HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan)
    ) implies (
      HEAT_OF_COFFEE.state = INCREASING and 
      TEMPERATURE_OF_COFFEE.state = INCREASING and 
      HEAT_OF_CUP.state = DECREASING and 
      TEMPERATURE_OF_CUP.state = DECREASING and 
      HeatFlow.increases = HEAT_OF_COFFEE and 
      HeatFlow.decreases = HEAT_OF_CUP
    )
}

fact {
  all t: ThermalThing | 
    (
      (Cup in t.touches or Coffee in t.touches) and 
      (HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan)
    ) implies (
      HEAT_OF_COFFEE.state = DECREASING and 
      TEMPERATURE_OF_COFFEE.state = DECREASING and 
      HEAT_OF_CUP.state = INCREASING and 
      TEMPERATURE_OF_CUP.state = INCREASING and 
      HeatFlow.increases = HEAT_OF_CUP and 
      HeatFlow.decreases = HEAT_OF_COFFEE
    )
}