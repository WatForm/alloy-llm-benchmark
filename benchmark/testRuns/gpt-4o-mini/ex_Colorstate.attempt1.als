abstract sig Color {
    Red, Yellow, Green
}

sig Light {}

sig LightState {
    color: Color
}

sig Junction {
    lights: set Light
}

fact {
    // Every LightState and a Light map to exactly one Color
    all ls: LightState, l: Light | ls.color in Color

    // For every LightState and every Junction, at most one of the Junction's lights has a color other than Red
    all ls: LightState, j: Junction | 
        #j.lights.light | (l: j.lights | ls.color != Red) <= 1
}