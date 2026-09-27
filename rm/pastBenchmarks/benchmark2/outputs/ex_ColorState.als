abstract sig Color {}
one sig Red, Yellow, Green extends Color {}

sig Light {}

sig LightState {
  colorOf: Light -> one Color
}

sig Junction {
  lights: set Light
}

fun redLights[s: LightState]: set Light {
  s.colorOf.Red
}

pred mostlyRed[s: LightState, j: Junction] {
  lone (j.lights - redLights[s])
}