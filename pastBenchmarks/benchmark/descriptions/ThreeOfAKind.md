In this Alloy model, there are two signatures: Card and Suit. The Card signature has a field called suit which relates each Card to a Suit.

A predicate in this model is named ThreeOfAKind. This predicate verifies a condition on a set of Cards, referred to as a hand. The conditions it verifies are: all Cards in the hand share the same suit, and that the total number of Cards in the hand is equal to three.

Finally, there is a command to run the ThreeOfAKind predicate with a maximum scope of 6.