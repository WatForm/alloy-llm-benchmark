enum Color { Red, Yellow, Green }

sig Light {}

sig LightState {
  color: Light -> one Color
}

sig Junction {
  lights: set Light
}

fact {
  all ls: LightState, j: Junction |
    lone l: j.lights | ls.color[l] != Red
}