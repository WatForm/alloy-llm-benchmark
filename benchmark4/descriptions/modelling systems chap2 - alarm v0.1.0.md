There are five disjoint sets of entities: "Condition", "Sensor", "Qualification", "Expert", and "State".

Each "Sensor" is associated to a set of "Condition"s called its "raise_alarm_on" "Condition"s. 

Each "Qualification"is associated with a non-empty set of "Condition"s called its "conditions".

Two different elements of "Qualification" cannot have exactly the same set of related "Condition"s. 

Each "Expert" is related to a non-empty set of "Qualification"s called its "qualifications".

Each "State" has a set of "Expert"s called is "called_experts".
It also has a set of "Expert"s called is "onsite_experts".
And it has a set of "Condition"s called its "current_alarms".

All "State"s can solve all alarms, meaning the "current_alarm"s of the state are within the "condition"s of the "qualification"s of the either the "onsite_expert"s of the state or the "called_expert"s of the state. 

No "Expert" is in both a state's "called_experts" and the state's "onsite_experts".

No expert in a state's "called_expert"s is unnecessary for solving that state's "current_alarms", meaning if you remove a "called_expert" of a state, it can no longer solve all alarms.
