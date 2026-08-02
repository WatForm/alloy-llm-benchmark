abstract sig Fruit {
  color: one Color,
  quality: one Quality,
  size: one Size
}

abstract sig Color {}
abstract sig Quality {}
abstract sig Size {}

one sig apple, orange extends Fruit {}

one sig RED, ORANGE extends Color {}

one sig Ripe, Juicy, Moldy, Brown, Organic extends Quality {}

one sig Large, Medium, Small extends Size {}

one sig FruitBowl {
  contains: set Fruit
}

fact {
  apple.color = RED
  orange.color = ORANGE
  FruitBowl.contains = apple + orange
}