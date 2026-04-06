In this model, we have several abstract elements:

- "Fruit" is an abstract entity and can represent any type of fruit.
- "Color" is an abstract property that can describe the color of a fruit. There are only two instances of color defined: RED and ORANGE.
- "Quality" is an abstract property that can describe the quality of a fruit. There are five instances of quality defined: Ripe, Juicy, Moldy, Brown, Organic.
- "Size" is an abstract property that can describe the size of a fruit. There are three instances of size defined: Large, Medium, Small.

Next, we have a singular item "FruitBowl" which contains a set of fruits.

Then, there are two specific types of fruit defined:
- "Apple" is a subtype of fruit which has properties of color, quality, and size. It can only be the color RED and can only have one quality and one size.
- "Orange" is a subtype of fruit which has properties of color, quality, and size. It can only be the color ORANGE, and similarly to the apple, it can only have one quality and one size.

These instances are restricted by the contained fruit set, which contains both the apple and the orange that belong to the fruit bowl.

Lastly, there's a predicate called "show". This does not specify any conditions or limitations, and when running the "show" command, it doesn't specify any scope or expected results.