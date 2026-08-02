// FRUIT BOWL
// Brett Kriz
abstract sig Fruit{}

abstract sig Color{}
one sig RED, ORANGE extends Color{ }

abstract sig Quality{}
one sig Ripe, Juicy, Moldy, Brown, Organic extends Quality{}


abstract sig Size{}
one sig Large, Medium, Small extends Size{}

one sig FruitBowl{
	contains: set Fruit
}

one sig apple extends Fruit{
	color:one RED,
	quality: one Quality,
	size: one Size
}

one sig orange extends Fruit{
	color: one ORANGE,
	quality: one Quality,
	size: one Size
}



fact{
	contains = FruitBowl -> apple + FruitBowl -> orange
}

pred show{}
run show
