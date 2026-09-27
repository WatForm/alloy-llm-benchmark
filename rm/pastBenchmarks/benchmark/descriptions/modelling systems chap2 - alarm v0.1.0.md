The Alloy model consists of the following signatures, fields, predicates, and commands:

Signatures:
1. Condition: This represents an event or situation which may need to be handled by an expert.
2. Sensor: This represents a device that can raise an alarm on a set of conditions.
3. Qualification: This represents a certain proficiency or skill required to handle a condition. A qualification consists of one or more conditions. However, no two qualifications can have the exact same set of conditions.
4. Expert: This represents a person who has a certain set of qualifications.
5. State: This represents the current status of the system. It comprises sets of called experts, onsite experts, and current alarms (conditions).

Pairs and Relations:
- A sensor can raise an alarm on a set of conditions.
- An expert has some qualifications.
- A qualification is associated with some conditions.
- The system state includes subsets of experts who have been called, experts who are onsite, and conditions that have raised current alarms.

Constraints:
- An expert can solve all alarms if all the alarms are included in the conditions of the expert's qualifications.
- The onsite and called experts in a given state must be able to solve all the current alarms in that state.
- There should not be any called experts who are also onsite.
- An expert can only be in the called_experts set if their removal from the set does not prevent the onsite and remaining called experts from being able to solve all current alarms.

Predicates:
- 'can_solve_all_alarms': This checks whether a given expert is able to solve a given set of conditions (alarms).
- 'called_experts_check': This verifies that the called and onsite experts in a state can handle all the current alarms in that state, and also that experts are only in the called_experts set if necessary.

Commands:
- A run command is executed with the aim of ensuring that all experts are either onsite or have been called, that there is at least one current alarm, and that all system constraints specified in the 'called_experts_check' predicate hold true. The command is run for 2, but only 1 State and 0 Sensor.
