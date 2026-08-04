sig Fruit {
    apple: one Fruit,
    orange: one Fruit
}

sig Color {
    RED: one Color,
    ORANGE: one Color
}

sig Quality {
    Ripe: one Quality,
    Juicy: one Quality,
    Moldy: one Quality,
    Brown: one Quality,
    Organic: one Quality
}

sig Size {
    Large: one Size,
    Medium: one Size,
    Small: one Size
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

fact FruitProperties {
    apple.color = Color.RED
    apple.quality in Quality
    apple.size in Size

    orange.color = Color.ORANGE
    orange.quality in Quality
    orange.size in Size
}

pred oneFruitBowl {
    one FruitBowl
}

run oneFruitBowl