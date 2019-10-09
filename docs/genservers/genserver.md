---
layout: default
---

# GenServer

# A quick example with raw processes
In order to illustrate the benefits of a GenServer, let's take a quick look at how we would implement a very simple state with raw processes. We're going to take a simple library process that needs to be able to add books to its library and be able to return the data when requested.

```elixir 
defmodule LibraryProcess do
  @default_books [
    "I love little ponies",
    "Next to the mountain is a rainbow",
    "Look at this little bear"
  ]

  # A simple start function to start this process
  def start(args), do: spawn(RawProcess, :init, [args])

  # Init will do the initial configuration such as:
  #   - Name registration
  #   - State configuration
  #   - ...
  def init(_args) do
    Process.register(self(), __MODULE__)
    loop(%{books: @default_books})
  end

  defp loop(state) do
    receive do
      {:get_all_books, pid} ->
        send(pid, {:response_books, state.books})
        loop(state)

      {:add_book, book} ->
        loop(%{books: [book | state.books]})
    end
  end
end
```

The process can be started with the `start/1` function, which then initializes the process. When the initialization is complete, an infinite loop that receives messages is called upon. When a message is sent towards the library process to e.g. retrieve the list of the books, it'll send back all the available books to the pid.

<!-- @Frederic, onderstaand stukje nodig? herschrijven? weglaten? Doe maar wat jou het beste lijkt. Dacht nog even kort te mentionen waarom dit onhandig is ivgm een genserver -->
_Note that in order to support this construction, this takes a lot of work. A lot can go wrong when manually managing loops, state updates, messages, unexpected messages, etc..._

This construction is so common, not to mention that there are a lot more common configuration parts not mentioned here, that this has been put in the GenServer behaviour. A GenServer, or generic server, is a process that has 2 parts defined in its module: the API and Server part.

To sum up some advantages:
* Standard set of interface functions (more about this later)
* Functionality for tracing and error reporting (we will not cover this extensively here, but it's worth noting)
<!-- Dit wil ik wel expliciet zeggen, ondanks het feit dat ze supervisors nog niet zien -->
* Fit into a supervision tree (more about this next lesson)

Putting it very concisely, in all the years that Erlang has proven itself as a battle-tested programming language, there have been several "constructs" that are so common and became boilerplate code. GenServer abstracts this away, so that you can just focus on the important bits.
<!--
  Eerder beginnen met het doel van een GenServer. Onderstaand is implementatiedetail.
  Beginnen met een simpel voorbeeld in "rauwe process-stijl" en dat upgraden naar een GenServer.

  DONE
-->


## GenServer vs Agent vs Task

If you want to know the difference, I couldn't explain it better than [this post](https://elixirforum.com/t/agent-task-genserver-genevent-what-do-you-use-it-for/2416/2?u=wfransen). A quick summary:

* A GenServer is a generic server used most of the time for a variety of use cases.
* An Agent is basically just a simplified GenServer.
* Tasks excel at asynchronous jobs that yield a result.

## Overview GenServer behaviour

Look at the slides for an overview of the GenServer API.

* **Client process:** uses `GenServer.start` or `GenServer.start_link` to start a GenServer process.
* **Server process:** calls the `init` function. You must make sure this phase doesn't take too long. If a lot of start up work has to be done after initializing the process, consider `handle_continue`. _Note that the argument from `GenServer.start` or `GenServer.start_link` is passed to the init function. This is most of the time a [keyword list](https://elixir-lang.org/getting-started/keywords-and-maps.html)._
* **Server process:** After the init function is complete, the process starts `receive`-ing messages in a loop.
* **Client/Server process:** The client will most often call a function, such as `MyGenServer.Counter.addone/0` or `MyGenServer.Counter.addone/1` (depends whether the process is name registered or not, more about that later), which will call the underlying `GenServer.cast`, `GenServer.call` or the basic `GenServer.send`.
   <!-- Betekent weinig in deze context. Eerder vermelden dat call een resultaat teruggeeft, cast niet. 
   DONE-->
  * Beware! `cast` doesn't return a result while `call` does.
  * You can specify your behaviour with `handle_cast`, `handle_call` and `handle_info`.
* **Server process:** The `terminate` callback is called when `GenServer.terminate` is called.

## A basic task handler

Imagine we have a GenServer keeping track of how many tasks can be executed at the same time and sends the response back to the initializer. This means that the GenServer will:

* Start tasks.
* Accumulate the tasks.
* Manage how many tasks are executed at the same time.
* Send the response back to the caller.
* Optionally make an API call available for the status.

That's a lot to maintain. Let us start with the beginning, starting the GenServer and registering the process.

### Initializing the GenServer

We define our module with the `use` macro:

```elixir
defmodule MyGenServer do
  use GenServer
end
```

You can compare `use` with "inheriting" from the `GenServer` module.
When you run this, you should see something like this:

```text
warning: function init/1 required by behaviour GenServer is not implemented (in module MyGenServer).

We will inject a default implementation for now:

    def init(init_arg) do
      {:ok, init_arg}
    end

You can copy the implementation above or define your own that converts the arguments given to `GenServer.start_link/3` to the server state.

  mygenserver.exs:1: MyGenServer (module)
```

Writing this documentation is easy if all I have to do is copy the output from elixir, but maybe some highlights:

`We will inject a default implementation` is a result of the `use` macro. Just like an interface, the GenServer behaviour requires us to implement some callbacks and the `init/1` function. When we write the `use` macro, we're actually allowing some other module to inject code into the current module. In this example, it has been detected that we didn't implement `init/1`. Though the GenServer behaviour requires this callback. Hence it injects the default implementation into our module.
<!-- Ik begrijp deze zin niet. 
 => Deze uitleg beter? Ik wil niet te hard ingaan op het feit dat de GenServer module dan __using__ implementeerd. Dit lijkt me vrij out of scope.
-->

Other than that, nothing is said of the API side which you will see most of the times (or is actually required). Let us refactor this:

```elixir
defmodule MyGenServer do
  use GenServer

  ##########
  #  API   #
  ##########
  def start(args), do: GenServer.start(__MODULE__, args, name: __MODULE__)

  ##########
  # SERVER #
  ##########
  def init(init_arg), do: {:ok, init_arg}
end
```

Wonderful. Compiling this doesn't throw any warnings or errors anymore. But what does this code do?

We can now call `MyGenServer.start/1` which causes `GenServer.start/3` to be executed which starts the GenServer without linking it to the current process. It takes 3 arguments:

<!-- Te veel detail. Uitstellen tot supervisors.
DONE -->
* `__MODULE__` refers to the current module's name. This is because the `init/1` function will be called after this on the specified module, as the warning already indicated. 
* The second being the arguments for the `init/1` function, more about this later. <!-- Lijkt me niet te kloppen. DONE -->
* The third parameter contains configuration data. Here you can configure the name registration, garbage collector, etc. A complete list can be found [here](https://hexdocs.pm/elixir/GenServer.html#t:option/0).

#### The `init/1` callback

<!-- Ik begrijp bovenstaande titel niet. Nergens staat er een waarschuwing. 
DONE -->

When we start a GenServer (e.g. `GenServer.start` or `GenServer.start_link`), the `init/1` callback is called upon. The process calling this function (e.g. your shell) will block until the response from your `init` function is returned. This is often frowned upon, as most of the heavy work necessary for computing your initials state is done in the `handle_continue` callback (we'll cover this later).

Let's first take a look at an example with basic argument passing:

```elixir
defmodule MyGenServer do
  use GenServer
  require IEx

  def start(args), do: GenServer.start(__MODULE__, args, name: __MODULE__)
  def init(args), do: IEx.pry()
end

MyGenServer.start([a: :value, b: :another_value])
```

Note: you can "pry" into a process with the IEx module. Keep in mind that you have to import it first using `require IEx`. When calling this with `iex -r mygenserver.exs`, you will see the following message:

```elixir
> $ iex mygenserver.exs
Request to pry #PID<0.109.0> at MyGenServer.init/1 (mygenserver.exs:20)

   18:   require IEx
   19:   def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
   20:   def init(args), do: IEx.pry()
   21: end
   22:

Allow? [Yn]
Interactive Elixir (1.9.1) - press Ctrl+C to exit (type h() ENTER for help)
pry(1)> args
[a: :value, b: :another_value]
```

Here you can see that the arguments have been passed automatically into the `init/1` function. This should normally reply with one of [these responses](https://hexdocs.pm/elixir/GenServer.html#c:init/1), but most likely you'll return something like `{:ok, state}` where state is a variable.

### Structs

Structs are basically maps where the presence of mandatory keys is checked at compile time. Maps also allow default values to be defined. We'll use it to define our limit of tasks that can be active at the time in our basic task handler.

Defining a struct for your module is accomplished with `defstruct`. When you use a combination of default values and implicit nil values, you must first specify the fields which implicitly default to `nil`.

```elixir
defmodule TaskHandler do
  use GenServer

  defstruct task_limit: 2, tasks: []

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def init(_args), do: {:ok, %TaskHandler{}}
end
```

In the above example, you can see that the `defstruct` has several default values which will be used as your initial state. Because a struct is a bare map underneath, we can use it like a normal map: 

```elixir
# Normal map usage
%{task_limit: 2, tasks: []}
# Usage as a struct (overriding default values)
%TaskHandler{task_limit: 4, tasks: []}
```

With the `defstruct task_limit: 2, tasks: []` statement, we've introduced default values. When we call `%TaskHandler{}`, we create a map (similar to the normal map usage), but we say that when no arguments are provided, we use the default values. If you want to override values, you can do this is the traditional way as you did with maps.
 <!-- Onduidelijk. -->

<!-- %TaskHandler{} uitleggen 
DONE -->


Adding `@enforce_keys` will enforce giving necessary parameters to create your struct. A possible implementation could be:

```elixir
defmodule TaskHandler do
  use GenServer

  defmodule TaskHandler.State do
    @enforce_keys [:task_limit]
    defstruct [:task_limit, tasks: []]
  end

  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def init(args), do: {:ok, struct!(TaskHandler.State, args)}
end
```

In this example, we won't work with mandatory keys. We simplify our code to:

```elixir
defmodule TaskHandler do
  use GenServer

  defstruct task_limit: 2, tasks: []

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def init(args), do: {:ok, struct(TaskHandler, args)}
end
```

Right now we're using named processes, or named GenServer to be precise. Therefore we do not need to worry about PID's, as we can always retrieve it with `Process.whereis(TaskHandler)`. This is very useful for processes where only one kind of this process is active. As soon as you need multiple processes of a module, this approach is no longer possible and you'll have to work with PID's. 

We will come back to this when we cover `handle_cast` and `handle_call`.
<!-- Nergens wordt dit gebruikt en 't nut ervan is niet duidelijk. 
DONE -->

### handle continue

Later on we'll see the complete implementation of this GenServer, but for now we'll just focus on the handle continue callback. As already mentioned before, we don't want to do long/expensive operations in our `init` function. That's why there is a handle continue callback, which assures that this is the first message in the mailbox. A simple example:

```elixir
defmodule TaskHandler do
  use GenServer
  defstruct task_limit: 2, tasks: [], queue: []

  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args), do: {:ok, struct(TaskHandler, args), {:continue, :start_recurring_tasks}}

  def handle_continue(:start_recurring_tasks, state) do
    send(self(), :check_tasks)
    {:noreply, state}
  end
end
```

In the `init/1` callback you can see that instead of just saying `{:ok, state}`, we return a 3 element tuple with `{:continue, :start_recurring_tasks}`. This assures that the first message in the mailbox, after the GenServer process is alive, is `:start_recurring_tasks` which needs to be handled with `handle_info`. In this case, we'll use it to send periodic "checks".

<!-- Zitten er dan messages in de mailbox voor dat de process geboren is?
Yes! Erbij geschreven ter verduidelijking DONE -->
_Note: the GenServer process is already alive when the function `init/1` is called!_

### handle info
<!-- Documentatie lijkt dit tegen te spreken.
FIXED -->
We've now got a GenServer with a message that can't be handled, i.e., `:check_tasks`. If we don't define a `handle_info` clause dealing with this message, our GenServer will log this message and ignore it. Let us implement this now:

```elixir
# Deal with empty queue: no tasks to be executed
def handle_info(:check_tasks, %{tasks: t, queue: []} = s) do
  # Separate alive from finished task processes
  {alive, _finished} = Enum.split_with(t, fn pid -> Process.alive?(pid) end)

  # Send reminder to self to check tasks after @check_time milliseconds
  Process.send_after(self(), :check_tasks, @check_time)

  # No return value, update process state
  {:noreply, %{s | tasks: alive}}
end

# Nonempty queue
def handle_info(:check_tasks, %{tasks: t, queue: [first_fun | rest]} = s) do
  # Send reminder to self to check tasks after @check_time milliseconds
  Process.send_after(self(), :check_tasks, @check_time)

  # Separate alive from finished
  Enum.split_with(t, fn pid -> Process.alive?(pid) end)
  |> case do
    {_alive, []} ->
      # Second list empty, i.e., there are no finished processes
      {:noreply, s}

    {alive, _finished} ->
      # Create process for next task, add to task list. Queue contains rest of tasks.
      {:noreply, %{s | tasks: [spawn(first_fun) | alive], queue: rest}}
  end
end
```

Note that we're using multi-clause functions for the same message. The `handle_info/2` has two parameters.

* The first parameter indicates the clause only deals with the `:check_tasks` message.
* The second parameter is the state that we defined in our `init/1` function.

So what does this code do? Let us start with the first function clause, the one where our queue is empty.
_To provide some extra information: This is just a GenServer which will keep a list of spawned PID's (which are not linked to this process!)._

First of all we check that the queue is empty. Though we do assign the list of spawned PID's to `t`, which is a list. After that we'll filter the dead tasks out of it (for now we don't mind about values which could be collected, like with Tasks, or any other kind of response values like `EXIT` or `DOWN` messages).

```elixir
{alive, _finished} = Enum.split_with(t, fn pid -> Process.alive?(pid) end)
```

Long story short, all the alive processes are in the `alive` variable and finished "tasks", or more accurately processes in this case, are ignored. After that we update the state with the alive tasks. Note that somewhere defined the module attribute `@check_time` which will be filled in **at compile time** in the code. This `Process.send_after/3` function will just resend the same message after `@check_time` seconds.

Now, this is quite simple when we have nothing in the queue. What if we do have something in the queue? That's what the second `handle_info` is for. After sending the message again, we do the similar higher order function `Enum.split_with` and pipe this into the case statement.

```elixir
Enum.split_with(t, fn pid -> Process.alive?(pid) end)
|> case do
  {_, []} -> {:noreply, s}
  {alive, _finished} -> {:noreply, %{s | tasks: [spawn(first_fun) | alive], queue: rest}}
end
```

Putting this very concisely: if there's no task finished yet, just wait. If there are finished processes, which we don't use (hence the `_` in the `_finished` variable), we update our current tasks with the PID of the new process.

Also note we are using the map short update syntax, which is `%{map | existing_key: new_value}`. We do this for the tasks key, and prepend the output of `spawn/1`, which is a PID, to the active tasks list.

Great, now the only remaining step is `handle_cast` and `handle_call`.

### `handle_cast` for asynchronous code
If we want to directly interact with our GenServer, which most likely is the case, you'll want to either use `handle_call` or `handle_cast`. Note that `handle_call` is a synchronous call, which is meant to give a response, while `handle_cast` is often used for "fire and forget" operations, thus being asynchronous.

In this case, we'll add a function to be executed in our task list or execute it immediately if our queue is lower than our `:task_limit` variable in our state.

```elixir
  def handle_cast({:add, fun}, %{tasks: t, queue: q, task_limit: tl} = s) when length(t) >= tl,
    do: {:noreply, %{s | queue: [fun | q]}}

  def handle_cast({:add, fun}, %{tasks: tasks} = s),
    do: {:noreply, %{s | tasks: [spawn(fun) | tasks]}}
```

Once again multi-clause functions allow us to write specific code for each function. The first one has a guard that checks whether we can still execute new tasks. If that's not possible, we just add it to the queue. If it is possible, we just start the process and add it to our remaining tasks.

### `handle_call` to retrieve information
The last important callback is `handle_call`. Keep in mind that this is synchronous and will block your client process until you receive a response! In our case, we'll just use it to dump the current state of the GenServer.

```elixir
  def handle_call(:status, _from, s), do: {:reply, s, s}
```

The `handle_call` function takes 3 parameters.

* The first one represents the message.
* The second parameter is a tuple of the caller PID with a unique reference.
* The third parameter contains the state.

After that, we have a range of choices of what to return. These choices are described [here](https://hexdocs.pm/elixir/GenServer.html#c:handle_call/3), but we're just replying the state (2nd element of the tuple) and the 3rd element of the tuple is the new state.

_Note: you can return a `:noreply` tuple, but it is still necessary to [return a reply](https://moosecode.nl/blog/elixir-tip-noreply-killer-feature)!_

## PID's vs name registration

As we've seen with `GenServer.cast` and `GenServer.call`, the first argument should be an identifier for the server. According to the documentation, this can either be a PID or a value representing the registered name. A tuple consisting of {atom, node} is also supported when working over multiple nodes.

## Overview

Note that this is a very rudimentary, unfinished, basic task handler. You'll almost never write such code in production, but this is just to illustrate the GenServer behaviour. If you want to create tasks dynamically, you'll most likely use a Dynamic Supervisor or a Task Supervisor. Here is the complete code:

```elixir
defmodule TaskHandler do
  use GenServer
  @check_time 100
  defstruct task_limit: 2, tasks: [], queue: []

  ##########
  # CLIENT #
  ##########
  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
  def status(), do: GenServer.call(__MODULE__, :status)

  def add_task(func) when is_function(func), do: GenServer.cast(__MODULE__, {:add, func})

  ##########
  # SERVER #
  ##########
  def init(args), do: {:ok, struct(TaskHandler, args), {:continue, :start_recurring_tasks}}

  def handle_cast({:add, fun}, %{tasks: t, queue: q, task_limit: tl} = s) when length(t) >= tl,
    do: {:noreply, %{s | queue: [fun | q]}}

  def handle_cast({:add, fun}, %{tasks: tasks} = s),
    do: {:noreply, %{s | tasks: [spawn(fun) | tasks]}}

  def handle_call(:status, _from, s), do: {:reply, s, s}

  def handle_info(:check_tasks, %{tasks: t, queue: []} = s) do
    {alive, _fin} = Enum.split_with(t, fn pid -> Process.alive?(pid) end)
    Process.send_after(self(), :check_tasks, @check_time)
    {:noreply, %{s | tasks: alive}}
  end

  def handle_info(:check_tasks, %{tasks: t, queue: [first_fun | rest]} = s) do
    Process.send_after(self(), :check_tasks, @check_time)

    Enum.split_with(t, fn pid -> Process.alive?(pid) end)
    |> case do
      {_, []} -> {:noreply, s}
      {alive, _fin} -> {:noreply, %{s | tasks: [spawn(first_fun) | alive], queue: rest}}
    end
  end

  def handle_continue(:start_recurring_tasks, state) do
    send(self(), :check_tasks)
    {:noreply, state}
  end
end

pid = self()

send_after_3_secs = fn ->
  :timer.sleep(3000)
  send(pid, :finished_3sec_function)
end

send_after_2_secs = fn ->
  :timer.sleep(2000)
  send(pid, :finished_2sec_function)
end

send_after_1_secs = fn ->
  :timer.sleep(1000)
  send(pid, :finished_1sec_function)
end

t = TaskHandler.start_link()
TaskHandler.add_task(send_after_3_secs)
TaskHandler.add_task(send_after_1_secs)
TaskHandler.add_task(send_after_2_secs)
TaskHandler.add_task(send_after_1_secs)
TaskHandler.add_task(send_after_3_secs)
```

_Note that this code does not provide any guarantees in which order the code is executed._

## Extra

Why didn't we use the task module? That's because you most likely want a response from your task, even if it is just `:ok`. This would mean that we have to use `Task.yield` or `Task.await`. Using these functions links the task to our current GenServer, which wouldn't be a wise choice. What if a user tries a simple function with `raise "oops"`? Our whole GenServer would crash with the complete queue. We can counteract this with a supervisor, but that's a little bit too early in this course.

_Note: There is a `Task.Supervisor.async_nolink/3`, but as the name implies it requires a Supervisor._
