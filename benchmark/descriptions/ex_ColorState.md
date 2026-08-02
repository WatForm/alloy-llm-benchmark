There is a set called "Color". Every element of "Color" is exactly one of "Red", "Yellow", or "Green". "Red", "Yellow", and "Green" are each single distinct elements of Color.

There is a set called "Light".

There is a set called "LightState". 
Every "LightState" and a "Light" map to exactly one "Color" in a relation called "color".

There is a set called "Junction". Each element of "Junction" has a relation called "lights" to a set of "Light" elements.

For every "LightState" and every "Junction", at most one of the "Junction"'s "lights" has a "color" other than "Red".

