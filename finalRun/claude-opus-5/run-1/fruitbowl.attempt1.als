abstract sig Fruit {
	color : one Color,
	quality : one Quality,
	size : one Size
}

abstract sig Color {}

abstract sig Quality {}

abstract sig Size {}

one sig apple extends Fruit {}
one sig orange extends Fruit {}

one sig RED extends Color {}
one sig ORANGE extends Color {}

one sig Ripe extends Quality {}
one sig Juicy extends Quality {}
one sig Moldy extends Quality {}
one sig Brown extends Quality {}
one sig Organic extends Quality {}

one sig Large extends Size {}
one sig Medium extends Size {}
one sig Small extends Size {}

one sig FruitBowl {
	contains : set Fruit
}

fact {
	apple.color = RED
	orange.color = ORANGE
	FruitBowl.contains = apple + orange
}