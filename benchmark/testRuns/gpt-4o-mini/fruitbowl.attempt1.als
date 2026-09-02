sig Fruit {
    apple: lone Fruit,
    orange: lone Fruit
}

sig Color {
    RED: lone Color,
    ORANGE: lone Color
}

sig Quality {
    Ripe: lone Quality,
    Juicy: lone Quality,
    Moldy: lone Quality,
    Brown: lone Quality,
    Organic: lone Quality
}

sig Size {
    Large: lone Size,
    Medium: lone Size,
    Small: lone Size
}

sig FruitBowl {
    contains: set Fruit
}

fact {
    // Distinct elements in Fruit
    apple != orange

    // Distinct elements in Color
    RED != ORANGE

    // Distinct elements in Quality
    Ripe != Juicy
    Ripe != Moldy
    Ripe != Brown
    Ripe != Organic
    Juicy != Moldy
    Juicy != Brown
    Juicy != Organic
    Moldy != Brown
    Moldy != Organic
    Brown != Organic

    // Distinct elements in Size
    Large != Medium
    Large != Small
    Medium != Small

    // FruitBowl contains exactly apple and orange
    FruitBowl.contains = FruitBowl.apple + FruitBowl.orange
}

// Preferences
apple.color = Color.RED
apple.quality in Quality
apple.size in Size

orange.color = Color.ORANGE
orange.quality in Quality
orange.size in Size

// Constraints
one FruitBowl
one apple
one orange