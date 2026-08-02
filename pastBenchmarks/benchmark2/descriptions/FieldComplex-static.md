The Alloy model described here entails three signatures: 'Field', 'Game', and 'Date'. Each 'Game' has a single 'Field' and a single 'Date' attached to it. 

There is also a special signature, 'FieldComplex', set up such that it has a set of 'Game' objects attached to it, labeled as 'schedule'. 

Under 'fact NotOnSchedule', it is explicitly stated that any 'Game' that is not listed in the 'schedule' of 'FieldComplex' must have neither a 'Field' nor a 'Date' attached to it. 

Under 'fact OnSchedule', we learn that any 'Game' that is indeed listed in the 'schedule' of 'FieldComplex' must have precisely one 'Field' and one 'Date' associated with it. 

The fact 'SameField' describes a situation where two distinct 'Game' objects sharing the same 'Field' cannot have the same 'Date'. This implies that there are unique dates for games played on the same field.

Additionally, two predicates are defined: 'ScheduledGame' and 'UnscheduledGame'. 

'ScheduledGame' checks whether there exists a game in the 'FieldComplex' schedule that has a specified 'Date' and 'Field'. This predicate is meant to confirm the presence of a scheduled game with all necessary fields filled in.

In contrast, 'UnscheduledGame' simply checks whether there exists a 'Game' that has not been scheduled, i.e. is not a part of 'FieldComplex' schedule. 

In the final command, we are insisting that both the conditions mentioned in the two predicates always hold true. 

In essence, this model is a specific approach to scheduling and managing games in a field complex, with built-in checks that prevent any game from lacking a 'Date' or a 'Field', or from clashing with another game at the same 'Field' on the same 'Date'.