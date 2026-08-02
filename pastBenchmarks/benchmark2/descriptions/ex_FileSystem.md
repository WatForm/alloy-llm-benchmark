This model consists of abstract signature Object and its three extensions: Directory, Root, and File. 

Object is an abstract entity that represents a type. Directory, Root, and File are specific types of Object. 

Directory is a specific type of Object and it has a set of Objects as its contents. Each Directory can have multiple Objects as its contents but an Object doesn't necessarily have to belong to a Directory's contents.

Root is a unique type of Directory that exists exactly once in this model.

File is another specific type of Object. It doesn't have any further properties.

There are a few constraints on these elements in the model:
1. No Directory can have itself in its transitive closure of contents. This means that a Directory cannot contain itself indirectly through another Directory. Therefore, cyclic containment is disallowed.
2. Every Object must be in the transitive closure of contents of Root. This ensures that all objects either directly or indirectly belong to the Root.
3. Except for the Root, every Object must have a unique Directory that it is directly contained in. Consequently, an Object cannot be present in multiple Directories at the same level in the hierarchy. Though it is allowed for an Object to be indirectly contained in multiple Directories.