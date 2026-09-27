This model represents a minimalistic family tree using the concepts of a Person, Man and Woman. 

In this model, a Person is an abstract type that can either be a Man or a Woman. Each Person has a relationship to a Man, defined as their father, and a relationship to a Woman, defined as their mother. None of these relationships are mandatory, and a Person can have either, neither, or both a father and a mother. 

A Man and a Woman are specific types of Person. A Man has a unique relationship with a Woman, defined as his wife, and a Woman has a unique relationship with a Man, defined as her husband. It's important to note that a Man's wife and a Woman's husband are particular Persons and a Man cannot have more than one wife, and a Woman cannot have more than one husband.

There are three vital constraints that this model adheres to:

1. Biology: This constraint indicates that a Person cannot be their own ancestor so that they can't be counted as part of either their mother's or father's lineage. 

2. Terminology: This constraint implies the reciprocal nature of the husband-wife relationship where a Man's wife is the same Woman who is his husband and vice versa. 

3. Social Convention: This constraint specifies that the interweaving of marriage and parent-child relationships (a Person's husband or wife cannot be in the same direct lineage denoted by their mother or father) is strictly forbidden. In other words, no Person could be related via parentage with their own spouse.