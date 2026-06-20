There is a set called "Object".

The elements of a set called "Directory" are all contained within "Object". Each element of "Directory" is related by "contents" to a set of elements of "Object".

There is exactly one element called "Root".

There is a set called "File" is a subset of "Object".

Every element of "Object" is either in "Directory" or in "File". No element can be in both "Directory" and "File".

No directory contains itself, which means no element of "Directory" is reachable from itself by following one or more steps of "contents".

Every element of "Object" is reachable from "Root" by following zero or more steps of "contents". 

Every element of "Object" other than "Root" is in the "contents" relation of exactly one element.