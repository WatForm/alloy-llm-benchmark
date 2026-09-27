abstract sig Fruit {
  color: one Color,
  quality: one Quality,
  size: one Size
}

one sig apple, orange extends Fruit {}

abstract sig Color {}
one sig RED, ORANGE extends Color {}

abstract sig Quality {}
one sig Ripe, Juicy, Moldy, Brown, Organic extends Quality {}

abstract sig Size {}
one sig Large, Medium, Small extends Size {}

one sig FruitBowl {
  contains: set Fruit
}

fact {
  apple.color = RED
  orange.color = ORANGE
  FruitBowl.contains = apple + orange
}