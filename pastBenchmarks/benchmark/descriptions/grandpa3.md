This model describes a simple family tree system, with entities being classified as either a "Person", "Man", or "Woman". It introduces several relationships between these entities.

Each "Person" can have zero or one "Man" as their "father", and likewise can have zero or one "Woman" as their "mother".

Each "Man" is also a "Person". Additionally, each "Man" can have zero or one "Woman" as their "wife".

Each "Woman" is also a "Person". Moreover, each "Woman" can have zero or one "Man" as their "husband".

Certain constraints, or 'facts', are imposed on these relationships. According to the "Biology" constraint, no person can exist within their own lineage, either through their "father" or "mother". The "Terminology" fact states that a "Man"'s "wife" is necessarily the "Woman" who identifies him as her "husband", and vice-versa. The "SocialConvention" fact makes sure there's no overlap between marital and parental relations.

The model also introduces a predicate or 'test' named "NoSelfFather". This test checks that no "Man" can be his own "father".

A function "grandpas" is defined that takes a "Person" as input and returns all the "Persons" who are "Men" and appear in the second generation of "Person"'s lineage. An additional predicate "ownGrandpa" is introduced that checks if a "Person" is his own grandfather.

Lastly, two versions of the "SocialConvention" are introduced as predicates: "SocialConvention1" corresponds to already defined "SocialConvention", while "SocialConvention2" defines it in a different way, considering that a man cannot be the husband of his daughter's mother and a woman cannot be the wife of her son's father. An assertion named "Same" is used to verify that both versions of "SocialConvention" are equivalent, in that they will both hold true or both hold false in all instances of the model.