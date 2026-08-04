sig Thing, Property, Process
sig ThermalThing extends Thing
sig ThermalProperty extends Property
sig HEAT, TEMPERATURE extends ThermalProperty

enum QuallitativeState {
  INCREASING,
  DECREASING,
  NOCHANGE
}

one sig Substance, Cup extends ThermalThing
one sig Coffee extends Substance

one sig TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends TEMPERATURE
one sig HEAT_OF_COFFEE, HEAT_OF_CUP extends HEAT

one sig HeatFlow extends Process

sig Thing {
  touches: one Thing,
  hasProperty: set Property
}

sig Property {
  influences: set Property,
  state: one QuallitativeState
}

sig HEAT {
  greaterThan: lone HEAT
}

sig Process {
  increases: one HEAT,
  decreases: one HEAT
}

fact {
  Thing = ThermalThing
  ThermalThing = Substance + Cup
  Process = HeatFlow
  ThermalProperty = Property

  HEAT + TEMPERATURE = ThermalProperty
  TEMPERATURE = TEMPERATURE_OF_COFFEE + TEMPERATURE_OF_CUP
  HEAT = HEAT_OF_COFFEE + HEAT_OF_CUP

  no HEAT & TEMPERATURE

  touches = ~touches
  no iden & touches

  greaterThan != ~greaterThan
  no iden & greaterThan

  hasProperty =
    Coffee -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE) +
    Cup -> (TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE)

  influences =
    HEAT_OF_COFFEE -> TEMPERATURE_OF_COFFEE +
    HEAT_OF_CUP -> TEMPERATURE_OF_CUP
}

fact {
  all t: ThermalThing |
    (t.touches & (Cup + Coffee) = none) implies {
      no HEAT.greaterThan
      no HeatFlow
    }
}

fact {
  all t: ThermalThing |
    (t.touches & (Cup + Coffee) != none) iff
      (
        HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
        or HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
        or (
          no (HEAT_OF_CUP.greaterThan & HEAT_OF_COFFEE)
          and no (HEAT_OF_COFFEE.greaterThan & HEAT_OF_CUP)
        )
      )
}

fact {
  all t: ThermalThing |
    (
      t.touches & (Cup + Coffee) != none
      and no (HEAT_OF_CUP.greaterThan & HEAT_OF_COFFEE)
      and no (HEAT_OF_COFFEE.greaterThan & HEAT_OF_CUP)
    ) implies {
      HEAT_OF_CUP not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.increases
      HEAT_OF_COFFEE not in HeatFlow.decreases
      HEAT_OF_CUP not in HeatFlow.decreases
    }
}

fact {
  all t: ThermalThing |
    (
      t.touches & (Cup + Coffee) != none
      and HEAT_OF_COFFEE in HEAT_OF_CUP.greaterThan
    ) implies {
      HEAT_OF_COFFEE.state = INCREASING
      TEMPERATURE_OF_COFFEE.state = INCREASING
      HEAT_OF_CUP.state = DECREASING
      TEMPERATURE_OF_CUP.state = DECREASING
      HeatFlow.increases = HEAT_OF_COFFEE
      HeatFlow.decreases = HEAT_OF_CUP
    }
}

fact {
  all t: ThermalThing |
    (
      t.touches & (Cup + Coffee) != none
      and HEAT_OF_CUP in HEAT_OF_COFFEE.greaterThan
    ) implies {
      HEAT_OF_COFFEE.state = DECREASING
      TEMPERATURE_OF_COFFEE.state = DECREASING
      HEAT_OF_CUP.state = INCREASING
      TEMPERATURE_OF_CUP.state = INCREASING
      HeatFlow.increases = HEAT_OF_CUP
      HeatFlow.decreases = HEAT_OF_COFFEE
    }
}