abstract sig Color {}
one sig Red extends Color {}
one sig Yellow extends Color {}
one sig Green extends Color {}

sig Light {}

sig LightState {
  color: Light -> one Color
}

sig Junction {
  lights: set Light
}

fact {
  all ls: LightState, j: Junction |
    #({l: j.lights | ls.color[l] != Red}) <= 1
}