This Alloy model describes some genealogical relationships in a toy model, including person/spouse relationships, parent/child relationships, and constraints related to marriage and parentage.

The model includes a primary abstract set named "Person", and every item in this set has at most one "spouse" and any number of "parents" (including zero). There are two subsets of Person: "Man" and "Woman".

There exists a scalar Man named "Adam", who is a unique individual within the set of Men. Similarly, there exists a scalar Woman named "Eve", who is a unique individual within the set of Women.

As for constraints, there are several. Firstly, the Biology fact constrains that no person can be his or her own ancestor. That is, no person should appear within their own 'ancestral' chain of parents.

The Bible fact contains several constraints: every person, except Adam and Eve, has exactly one mother and one father. These parents are members of the Woman and Man sets, respectively. Adam and Eve, however, have no parents. In this model, Adam's spouse is specifically Eve.

The social norms fact includes further constraints. According to this, no person can be his or her own spouse. Moreover, the spouse relation is symmetric; that is, for any person, if they are the spouse of another person, then that other person is also their spouse. Moreover, the spouse of a Man should always be a Woman, and vice versa.

The NoIncest fact includes constraints that prevent certain forms of 'incest' in the model. Specifically, a sibling (defined as someone who shares at least one parent) cannot be a spouse. Similarly, a person cannot be a spouse of their own parent.

The predicate "Show" is unspecified in this model, but indicates that it refers to some scenario that is neither Adam nor Eve having a spouse.

Lastly, a command is run for the scenario illustrated by "Show", bringing up three instances and expecting one solution. This implies a particular expected allocation and association of individuals, but the model as currently set up does not allow any valid solutions.