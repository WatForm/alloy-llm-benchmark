sig Thing {}

sig Property {
    influences: set Property,
    state: QuallitativeState
}

enum QuallitativeState {
    INCREASING, 
    DECREASING, 
    NOCHANGE
}

sig Process {}

sig ThermalThing extends Thing {}

one sig Substance extends ThermalThing {}
one sig Cup extends ThermalThing {}
one sig Coffee extends Substance {}

sig ThermalProperty extends Property {}

subset ThermalProperty = Property
sig HEAT extends ThermalProperty {}
sig TEMPERATURE extends ThermalProperty {}

one sig TEMPERATURE_OF_COFFEE extends TEMPERATURE {}
one sig TEMPERATURE_OF_CUP extends TEMPERATURE {}

one sig HEAT_OF_COFFEE extends HEAT {}
one sig HEAT_OF_CUP extends HEAT {}

one sig HeatFlow extends Process {}

rel touches: Thing -> Thing
rel hasProperty: Thing -> Property
rel greaterThan: HEAT -> HEAT

fact {
    // Every Thing relates to exactly one Thing in touches
    all t: Thing | lone t.touches
    // touches relation is symmetric
    all t1, t2: Thing | t1.touches.touches[t2] implies t2.touches.touches[t1]
    
    // Each Thing has zero or more Properties
    all t: Thing | t.hasProperty in Property
    
    // Properties influence attributes
    HEAT_OF_COFFEE.influences = TEMPERATURE_OF_COFFEE
    HEAT_OF_CUP.influences = TEMPERATURE_OF_CUP
    
    // Distinct properties defined
    HEAT_OF_COFFEE.hasProperty = HEAT_OF_COFFEE
    HEAT_OF_CUP.hasProperty = HEAT_OF_CUP
    Coffee.hasProperty = TEMPERATURE_OF_COFFEE + HEAT_OF_COFFEE
    Cup.hasProperty = TEMPERATURE_OF_CUP + HEAT_OF_CUP
    
    // Properties for Coffee and Cup only
    all t: ThermalThing | t.hasProperty = (Coffee.hasProperty + Cup.hasProperty) implies t in Coffee + Cup
}

fact {
    // greaterThan relation properties
    all h: HEAT | h.greaterThan != h
    all h1, h2: HEAT | h1.greaterThan[h2] implies not h2.greaterThan[h1]
}

fact {
    // Heat flow constraints
    all t: ThermalThing | (t.touches in Cup + Coffee) implies 
        (HEAT_OF_COFFEE.greaterThan[HEAT_OF_CUP] or 
         HEAT_OF_CUP.greaterThan[HEAT_OF_COFFEE] or 
         not (HEAT_OF_COFFEE.greaterThan[HEAT_OF_CUP] or 
              HEAT_OF_CUP.greaterThan[HEAT_OF_COFFEE]
         )
    )
}

fact {
    all t: ThermalThing | (t.touches in Cup + Coffee) and 
    not (HEAT_OF_COFFEE.greaterThan[HEAT_OF_CUP] or 
         HEAT_OF_CUP.greaterThan[HEAT_OF_COFFEE]) implies 
         (not HeatFlow.increases[HEAT_OF_CUP] and 
          not HeatFlow.increases[HEAT_OF_COFFEE] and 
          not HeatFlow.decreases[HEAT_OF_COFFEE] and 
          not HeatFlow.decreases[HEAT_OF_CUP])
}

fact {
    all t: ThermalThing | (t.touches in Cup + Coffee) and 
    HEAT_OF_CUP.greaterThan[HEAT_OF_COFFEE] implies 
         (HEAT_OF_COFFEE.state = INCREASING and 
          TEMPERATURE_OF_COFFEE.state = INCREASING and 
          HEAT_OF_CUP.state = DECREASING and 
          TEMPERATURE_OF_CUP.state = DECREASING) and 
          (only HeatFlow.increases[HEAT_OF_COFFEE] and 
           only HeatFlow.decreases[HEAT_OF_CUP])
}

fact {
    all t: ThermalThing | (t.touches in Cup + Coffee) and 
    HEAT_OF_COFFEE.greaterThan[HEAT_OF_CUP] implies 
         (HEAT_OF_COFFEE.state = DECREASING and 
          TEMPERATURE_OF_COFFEE.state = DECREASING and 
          HEAT_OF_CUP.state = INCREASING and 
          TEMPERATURE_OF_CUP.state = INCREASING) and 
          (only HeatFlow.increases[HEAT_OF_CUP] and 
           only HeatFlow.decreases[HEAT_OF_COFFEE])
}