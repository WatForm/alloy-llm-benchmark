abstract sig Thing {
  touches: set Thing,
  hasProperty: set Property
}

abstract sig Property {
  influences: set Property,
  state: one QuallitativeState
}

abstract sig Process {
  increases: set Property,
  decreases: set Property
}

abstract sig QuallitativeState {}
one sig INCREASING, DECREASING, NOCHANGE extends QuallitativeState {}

abstract sig ThermalThing extends Thing {
  greaterThan: set Property
}

abstract sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

abstract sig ThermalProperty extends Property {}
one sig HEAT, TEMPERATURE extends ThermalProperty {}

one sig HEAT_OF_COFFEE, HEAT_OF_CUP, TEMPERATURE_OF_COFFEE, TEMPERATURE_OF_CUP extends ThermalProperty {}

one sig HeatFlow extends Process {}

fact TouchFacts {
  no t: Thing | t in t.touches
  all t1, t2: Thing | t1 in t2.touches iff t2 in t1.touches
}

fact PropertyAssignmentFacts {
  Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
  Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
}

fact InfluenceFacts {
  HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
  HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
}

fact ThermalThingRestrictionFacts {
  all t: ThermalThing - Cup - Coffee | no t.greaterThan
}

fact GreaterThanTyping {
  all t: ThermalThing | t.greaterThan in HEAT_OF_COFFEE + HEAT_OF_CUP
}

fact HeatFlowParticipationFacts {
  all t: ThermalThing - Cup - Coffee |
    t in Cup.touches + Coffee.touches implies
      (t.greaterThan = HEAT_OF_COFFEE or t.greaterThan = HEAT_OF_CUP)
}

fact HeatFlowNoEffectWithoutGreaterThan {
  all t: ThermalThing |
    t in Cup.touches + Coffee.touches and no t.greaterThan implies
      no (HeatFlow.increases & (HEAT_OF_CUP + HEAT_OF_COFFEE)) and
      no (HeatFlow.decreases & (HEAT_OF_CUP + HEAT_OF_COFFEE))
}

fact HeatFlowBehaviorFacts {
  all t: ThermalThing |
    t in Cup.touches + Coffee.touches implies (
      (t.greaterThan = HEAT_OF_COFFEE) implies (
        HeatFlow.increases = HEAT_OF_CUP and
        HeatFlow.decreases = HEAT_OF_COFFEE and
        HEAT_OF_CUP.state = INCREASING and
        HEAT_OF_COFFEE.state = DECREASING and
        TEMPERATURE_OF_CUP.state = INCREASING and
        TEMPERATURE_OF_COFFEE.state = DECREASING
      )
      else
      (t.greaterThan = HEAT_OF_CUP) implies (
        HeatFlow.increases = HEAT_OF_COFFEE and
        HeatFlow.decreases = HEAT_OF_CUP and
        HEAT_OF_COFFEE.state = INCREASING and
        HEAT_OF_CUP.state = DECREASING and
        TEMPERATURE_OF_COFFEE.state = INCREASING and
        TEMPERATURE_OF_CUP.state = DECREASING
      )
    )
}

pred show {}

run show