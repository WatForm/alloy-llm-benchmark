abstract sig Fruit {
  color: one Color,
  quality: one Quality,
  size: one Size
}

one sig apple extends Fruit {}
one sig orange extends Fruit {}

abstract sig Color {}

one sig RED extends Color {}
one sig ORANGE extends Color {}

abstract sig Quality {}

one sig Ripe extends Quality {}
one sig Juicy extends Quality {}
one sig Moldy extends Quality {}
one sig Brown extends Quality {}
one sig Organic extends Quality {}

abstract sig Size {}

one sig Large extends Size {}
one sig Medium extends Size {}
one sig Small extends Size {}

one sig FruitBowl {
  contains: set Fruit
}

fact appleColor {
  apple.color = RED
}

fact orangeColor {
  orange.color = ORANGE
}

fact bowlContents {
  all b: FruitBowl | b.contains = apple + orange
}