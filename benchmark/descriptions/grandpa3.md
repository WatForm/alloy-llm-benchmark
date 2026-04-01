The Alloy model describes a system of familial relationships with some biological and societal rules. 

The system includes a set of "Persons". Each person can be associated with at most one "Man" as a father and at most one "Woman" as a mother. 

The "Man" and "Woman" sets are sub-sets of the "Person" set. Each man in the system can have at most one woman as a wife. Each woman in the system can have at most one man as a husband. 

There are some rules, or facts, about these relationships. 

The "Biology" fact states that no person can be their own ancestor, meaning a person cannot be in the transitive closure of their own mother and father. 

The "Terminology" fact states that a man's wife is necessarily the woman who considers the man her husband, and vice versa.

The "SocialConvention" fact states that there are no intersections between the relationships of being a mother/father (including their transitive closures) and the relationships of being a wife/husband in the system.

There are also assertions in this model.

The assertion "NoSelfFather" states that no man can be his own father.

The function "grandpas" returns a set of a person's 'grandparents' which includes the mother and father of that person's parents, and also includes the husbands of their maternal and paternal grandmothers. 

The predicate "ownGrandpa" checks if a person is their own grandpa.

Command "check NoSelfFather" confirms that the assertion "NoSelfFather" is satisfied in the model over 4 people.

Command "run ownGrandpa for 4 Person" generates a model instance over 4 people where a person is their own grandpa.

The predicate "SocialConvention1" checks the same condition as the "SocialConvention" fact.

Another predicate "SocialConvention2" checks that no man or woman's spouse is a descendant of the man or woman through their own mother or father, respectively.

Finally, the assertion "Same" states that "SocialConvention1" and "SocialConvention2" are equivalent, and a command checks that this assertion is true in the model.