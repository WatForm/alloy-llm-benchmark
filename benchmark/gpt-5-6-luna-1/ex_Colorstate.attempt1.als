abstract sig Color {}

one sig Red, Yellow, Green extends Color {}

sig LightState {
    color: Light -> one Color
}

sig Light {}

sig Junction {
    lights: set Light
}

fact {
    all state: LightState, junction: Junction |
        lone (junction.lights & state.color.(Color - Red))
}