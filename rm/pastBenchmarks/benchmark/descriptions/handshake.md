The model defines three signature sets called Person, Jocelyn, and Hilary. Jocelyn and Hilary are both specialized sets of Person. Each person has a spouse who is a Person, and has shaken hands with a set of Persons.

The model includes a set of rules regarding handshaking and marriage:

- No Person may shake hands with their spouse or themselves. In other words, the intersection of a person, their spouse and the set of people they have shaken hands with should be an empty set.
- Handshakes are reciprocated. This means if one person has shaken hands with another, then the another person has also shaken hands with the first one.
- Spouses are mutually exclusive; no person can be their own spouse. Moreover, if one person is the spouse of another, then that other person is the spouse of the first. Thus, spouses are reciprocal.
- A person's spouse's spouse must be that person. This reinforces the previous rule that the spouse relationship is reciprocal.
- The condition that a person is not their own spouse is repeated, which is likely to ensure that this condition is strictly adhered to.

In terms of specific individuals, Hilary's spouse is Jocelyn. 

There are also some conditions related to the number of handshakes conducted by people who are not Jocelyn. Though the exact number of people shaking hands is not specified, any two such people must not have shaken hands with the same number of individuals. This rule does not apply to Jocelyn.

The model also includes three commands named Puzzle, which take two parameters; a fixed number of persons (10, 12, 14, or 16) and a fixed number of integers (either 5 or 6). Each command expects a single valid instance of the model to exist under these constraints.