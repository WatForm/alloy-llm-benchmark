The Alloy model consists of three signatures, or sets of entities: 'Field', 'Game', and 'Date'. There is also a global singleton, 'FieldComplex', related to the set of all games. 

Each entity of type 'Game' is associated with a single field ('where') and a single date ('when'). The 'FieldComplex' is responsible for scheduling games and has a set of games ('schedule'). 

There are three facts in this model. 'NotOnSchedule' states that any game not present in the 'FieldComplex' schedule does not have an associated field or date. 'OnSchedule' states that any game that is on the 'FieldComplex' schedule will have exactly one associated field and one date. 'SameField' states that if two games have the same field, they must have different dates. These facts effectively limit how games, fields, and dates can be associated. 

In addition to these, the model specifies two predicates. The 'ScheduledGame' predicate checks that there is at least one game with a date and a field in the schedule of the 'FieldComplex'. Conversely, the 'UnscheduledGame' predicate checks for the existence of at least one game that is not on the schedule. 

Lastly, the model specifies a command intended to explore the state space of the model. The command requires that both the 'ScheduledGame' and 'UnscheduledGame' predicates are satisfied and the model is run in a scope of five, meaning it is examining five entities of each signature.