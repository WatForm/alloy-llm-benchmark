module language/grandpa3 ---- the final model in fig 4.4

abstract sig Person {
	father: lone Man,
	mother: lone Woman
	}

sig Man extends Person {
	wife: lone Woman
	}

sig Woman extends Person {
	husband: lone Man
	}

fact Biology {
	no p: Person | p in p.^(mother+father)
	}

fact Terminology {
	wife = ~husband
	}

fact SocialConvention {
	no (wife+husband) & ^(mother+father)
	}
