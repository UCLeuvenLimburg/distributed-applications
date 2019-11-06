# Task

From node A, spawn a function printing "Hello world on node: shortname@somehost" on node B.

* previous exercise is a requirement for this exercise.
* use Node.spawn/2 in order to spawn a function. This is similar to a normal spawn, but this time you have to provide an extra argument being the node.

Verify this by running the code in your current shell. This should print something like:

`Hello world on node: ping@wannes-Latitude-7490`

Now do the same, but run the code on the other node (without using the other node its shell):

`Hello world on node: pong@wannes-Latitude-7490`
