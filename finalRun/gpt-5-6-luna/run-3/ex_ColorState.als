abstract sig Color {}

one sig Red, Yellow, Green extends Color {}

sig LightState, Light {
    color: one Color
}

sig Junction {
    lights: set Light
}

fact {
    all ls: LightState, j: Junction |
        lone { l: j.lights | l.color != Red }
}