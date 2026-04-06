This is a model in the Alloy language that depicts the interaction between 'Cup' and 'Coffee', described as 'ThermalThings', and the properties they possess.

Signatures:
The model has several signatures, with 'Thing' as the abstract parent signature. Other distinctive signatures include 'Property', 'Process', 'QuallitativeState', 'Thing' and their respective children signatures.

'Thing': It is connected to another 'Thing' via the 'touches' relation, and it has some properties described by 'hasProperty'.

'Property': It can influence other 'Properties' via 'influences' relation and also has a quallitative state via 'state' relation.

'QuallitativeState': It has three extended signatures 'INCREASING', 'DECREASING', and 'NOCHANGE'. None of them have relationships with other signatures, but they are used in the model to establish relationships.

There are explicit instances of 'ThermalThing', 'Substance', 'Cup', 'Coffee', 'HEAT', 'ThermalProperty', 'TEMPERATURE', 'HEAT_OF_COFFEE', 'HEAT_OF_CUP', 'TEMPERATURE_OF_COFFEE', 'TEMPERATURE_OF_CUP' and 'HeatFlow'. There are relationships among these instances, which are governed by the rules detailed below in 'facts'.

Facts:
- There is no 'Thing' that touches itself.
- If a 'Thing' touches another 'Thing', the latter also touches the former.
- The properties of 'Coffee' are 'TEMPERATURE_OF_COFFEE' and 'HEAT_OF_COFFEE'. Similarly, the properties of 'Cup' are 'TEMPERATURE_OF_CUP' and 'HEAT_OF_CUP'.
- 'HEAT_OF_COFFEE' influences 'TEMPERATURE_OF_COFFEE' and 'HEAT_OF_CUP' influences 'TEMPERATURE_OF_CUP'.
- If a 'Thermal Thing' is neither a 'Cup' nor a 'Coffee', it does not have the 'greaterThan' relation, nor is it a part of 'HeatFlow'.
- If a 'ThermalThing' touches either the 'Cup' or the 'Coffee', it will have a 'greaterThan' relation pointing from 'HEAT_OF_COFFEE' to 'HEAT_OF_CUP' or vice versa but not both at the same time.
- If the 'ThermalThing' touching the 'Cup' or the 'Coffee' does not have the 'greaterThan' relation, 'increases' and 'decreases' do not point from 'HeatFlow' to 'HEAT_OF_CUP' or 'HEAT_OF_COFFEE'.
- There are rules which dictate the 'state', 'increases' and 'decreases' relation if a 'ThermalThing' touching the 'Cup' or the 'Coffee' have the 'greaterThan' relation from 'HEAT_OF_CUP' to 'HEAT_OF_COFFEE' or vice versa.

Predicates and commands:
The model has one named predicate - 'show' which does not have any operations/commands defined under it, so it has no effect. This predicate can be used to display the results of the declarations and facts in the model. A command 'run show' is present at the end to run this predicate.