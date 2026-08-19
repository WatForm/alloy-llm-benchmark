sig Fruit {
  color: one Color,
  quality: one Quality,
  size: one Size
}

one sig apple, orange extends Fruit {}

sig Color {}

one sig RED, ORANGE extends Color {}

sig Quality {}

one sig Ripe, Juicy, Moldy, Brown, Organic extends Quality {}

sig Size {}

one sig Large, Medium, Small extends Size {}

one sig FruitBowl {
  contains: set Fruit
}

fact {
  Fruit = apple + orange
  Color = RED + ORANGE
  Quality = Ripe + Juicy + Moldy + Brown + Organic
  Size = Large + Medium + Small

  apple.color = RED
  orange.color = ORANGE

  FruitBowl.contains = apple + orange
}