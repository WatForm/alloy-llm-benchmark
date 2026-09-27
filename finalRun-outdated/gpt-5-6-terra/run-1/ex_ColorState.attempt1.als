abstract sig Color {}

one sig Red, Yellow, Green extends Color {}

sig Light {}

sig LightState {
  color: Light -> one Color
}

sig Junction {
  lights: set Light
}

fact {
  all s: LightState, j: Junction |
    lone (j.lights & s.color.(Color - Red))
}