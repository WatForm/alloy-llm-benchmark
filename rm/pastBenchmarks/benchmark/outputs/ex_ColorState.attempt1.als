abstract sig Color {}
one sig Red, Yellow, Green extends Color {}

sig Light {}

sig Junction {
  lights: set Light
}

fact DisjointJunctionLights {
  all disj j1, j2: Junction | no (j1.lights & j2.lights)
}

sig LightState {
  colorOf: Light one -> one Color
}

fun redLights[s: LightState]: set Light {
  s.colorOf.Red
}

pred mostlyRed[s: LightState, j: Junction] {
  #(j.lights - redLights[s]) <= 1
}