abstract sig Fruit {
  color: one Color,
  quality: one Quality,
  size: one Size
}

sig apple extends Fruit {}
sig orange extends Fruit {}

abstract sig Color {}
one sig RED, ORANGE extends Color {}

abstract sig Quality {}
one sig Ripe, Juicy, Moldy, Brown, Organic extends Quality {}

abstract sig Size {}
one sig Large, Medium, Small extends Size {}

sig FruitBowl {
  contains: set Fruit
}

fact FruitColors {
  all a: apple | a.color = RED
  all o: orange | o.color = ORANGE
}

fact BowlContainsApplesAndOranges {
  all b: FruitBowl | b.contains = apple + orange
}