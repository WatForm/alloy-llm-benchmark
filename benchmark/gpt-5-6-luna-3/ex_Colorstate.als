abstract sig Color {}

one sig Red, Yellow, Green extends Color {}

sig LightState, Light {
    color: one Color
}

sig Junction {
    lights: set Light
}

fact {
    all state: LightState, junction: Junction |
        lone { light: junction.lights | light.color != Red }
}