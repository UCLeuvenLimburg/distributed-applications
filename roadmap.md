# Roadmap

* Essence of functional programming
* Language
  * Modules
  * Functions
    * Guards
    * Multiple clauses
    * Default parameter values
  * Optional `return`
  * No loops, replaced by h.o.f.
  * Tuples
  * Atoms
  * Maps
  * Pattern matching
  * Interpolated strings
  * Structs
  * Piping
* Lambdas
  * `&func/arity` syntax
  * Closures
  * Existing higher order functions
    * `map`
    * `filter`
    * `reduce`
    * `all?`, `any?`
    * `count`
    * `max_by`, `min_by`
    * `sort_by`
* Processes
  * `spawn`
  * `send`, `receive`

|Week|Topics|Size|Newness|
|-|-|-|-|
| 1 | Basic syntax, data structures, maps, lists, linked lists. | 10 | 2 |
| 2 | Lambda, closures, HOF. | 7 | 7 |
| 3 | Processes, message passing, ping-pong application. | 2 | 9 |
| 4 | Tasks, links, monitors, GenServers | 6 | 10 |
| 5 | Supervisors, Dynamic Supervisors | 4.5 | 6 |
| 6 | Creating our first API consuming service | 1 | 1 |
| 7 | Making our API consuming service fault-tolerant and let it control its resources queuing | 3 | 4 |
| 8 | Distributing a task intensive service (Master-slave setup) | 5 | 5 |
| 9 | Kubernetes or Docker swarm | ? | ? |
| 10 | Failover and takeover nodes | ? | ? |
| Opt | Overflowing | ? | ? |
