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
    all state: LightState, j: Junction | lone l: j.lights | l.(state.color) != Red
}