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
  all ls: LightState, j: Junction |
    lone (j.lights & ls.color.(Color - Red))
}