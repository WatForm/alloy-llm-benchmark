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
    all state: LightState, junction: Junction |
        lone { light: junction.lights | state.color[light] != Red }
}