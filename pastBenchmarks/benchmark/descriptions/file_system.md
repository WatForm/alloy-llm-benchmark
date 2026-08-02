This model represents a generic file system. The file system contains different types of objects. A type of object is known as "Name". The objects in the file system may be of two kinds: "File" and "Dir". 

"File" is an extension of the "Object". A file is contained in at least one directory, which means that there exists at least one directory "d" such that the file is in the content of the entries of the directory "d".

The "Dir" is another extension of the "Object". A directory may have multiple directory entries, represented by the set "entries". A directory may also have at most one parent directory, represented by "parent". A directory's parent must also contain that directory in the contents of its entries. All the entries in a directory must have distinct names, that is, if two entries have the same name, then they must be the same entry. Furthermore, a directory can't be a parent of itself and there should not be a cycle of parents. If a directory is not the "Root" directory, then it must be a descendant of the "Root" directory.

One singular "Root" directory extends from "Dir". The "Root" directory doesn't have a parent.

There is at most one current directory represented by "Cur" that also extends from "Dir".

A directory entry, represented by the signature "DirEntry", consists of a name (which is a "Name") and contents (which is an "Object"). Each directory entry must belong to exactly one directory.

The predicate "OneParent_buggyVersion" stipulates that all directories, excluding the root, should have exactly one parent.

The corrected version of above, "OneParent_correctVersion", states that all directories, excluding the root, should have exactly one parent and that the directory should exist in the contents of exactly one directory entry.

The predicate "NoDirAliases" asserts that a directory may be the contents of at most one directory entry.

There are two checks in the model. The first check confirms whether, if the predicate "OneParent_buggyVersion" holds, the predicate "NoDirAliases" also holds, within a scope of 5. The expected result is one counterexample. The second check verifies whether, if the predicate "OneParent_correctVersion" holds, the predicate "NoDirAliases" also holds, within a scope of 5. The expected result is no counterexample.