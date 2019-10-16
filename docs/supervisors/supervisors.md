---
layout: default
---

# Supervisors

We know that it is possible with monitors or links to receive messages when another process dies. However, in order to restart such processes, we need to implement a lot of boilerplate code for every exit message. Supervisor processes are meant to alleviate this burden. They are used to build hierarchical process structures, also known as the supervision tree.

## A default mix application

Although it is possible to make your supervisors in your iex shell or spawn them using scripts, we're going to use mix to create a new project with a default, application-level supervisor.

Open your terminal, go to wherever you want to create your project and execute the following command:

```bash
$ mix new [PROJECT_NAME] --sup
```

You'll see that a lot of files have been added. Mix is a tool that allows you to easily manage project dependencies, tests, and much more. For now we'll use it to generate a project with a very basic supervision tree.

A quick overview of some files:

* `lib/*` contains your application code
* `test/*` contains your test runners, helpers, etc.
* `formatter.exs` is for application-wide formatting (so that your code is formatted consistently).
* `mix.exs` is used for dependency, project, application management. You can also make your own 'mix commands'.

Below are a few common mix commands:

* mix run
* mix compile
* mix deps.get
* mix deps.compile
* mix test

Note that you'll often want to run an interactive shell within your application, this can be achieved with `iex --werl -S mix run` (Linux users don't need to add the `--werl`). If you don't want the interactive shell but still want your application to keep running then use the `mix run --no-halt` command.

Now that you've got a skeleton application, let's get started with our first supervisor.

## Application supervisor

We've all heard about Erlang achieving 99.9999999% uptime. Fault-tolerant behaviours might be one of the most important factors to achieve this high uptime. Sometimes, due to strange and unforeseen circumstances, a process might crash. We don't want our whole application to go down with a very long stacktrace, but restart it immediately so that our uptime is preserved.

This is what our Supervisors are for. Their sole responsibility is to monitor __linked__ processes and restart them whenever necessary. Though in order to do that, the supervisor needs to know 3 things:

* How it should start the child.
* What it should do when the child terminates.
* How, or by what term, it should uniquely distinguish the child.

This collection of information is called a child specification. Later on we'll cover child specifications in-depth, but for now just know that they exist.

## A very simple process

We're going to create a very simple message that can receive a message and print its own pid. In order to illustrate it even better, it should also be able to receive a message that, when received, causes the process to die. The module will probably look something like:

```elixir
defmodule SampleProject.Demo do
  def start_link(_args \\ []) do
    # Spawn linked process
    pid = spawn_link(__MODULE__, :receive_messages, [])

    # Give newly spawned process the name "demo"
    Process.register(pid, :demo)

    {:ok, pid}
  end

  def receive_messages() do
    receive do
      :print_pid -> IO.puts("#{inspect(self())}")
      :die -> Process.exit(self(), :kill)
    end

    receive_messages()
  end
end
```

First of all, let's start with the `start_link/1` function. We will conform to the other OTP behaviours and provide a `start_link` function to easily start our process. We aren't doing something with the arguments `[]`, so we can ignore this. After that we start the process with the module, function and arguments parameter. The next step is the name registration. With GenServer you can pass a `:name` option, but when manually creating processes we don't have that luxury. The `Process.register/2` allows us to do this for us.

Then there is finally the `{:ok, pid}` which we return. If you look at the [`GenServer.start_link`](https://hexdocs.pm/elixir/GenServer.html#start_link/3) function, you'll see that this can return a tuple with `:ok` or `:error` (where the second value is either the pid or the reason why it couldn't start). The Supervisor is expecting a similar result, hence we wrap this in a tuple.

After registering and starting your process, it should be waiting for messages (when you start it; right now we don't start the process yet). Before we're going to send messages, let us look at something else. Type the following command in your iex shell:

```elixir
iex(1)> :observer.start
```

Then press the "Applications" tab. Here you can see your whole supervision tree. This is a great tool if you want a simple GUI to see your memory load, process trees, etc. _Note that some processes just have PID's and not names. That's because those processes are not name registered._

## Starting our process under the application supervisor

Now that we got our process ready to be spun up, all that remains is to add it to our supervisors children. In order to do that, let's first see what's already written in the `lib/project_name/application.ex` file.

```elixir
def start(_type, _args) do
    children = [
      # Starts a worker by calling: SampleProject.Worker.start_link(arg)
      # {SampleProject.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SampleProject.Supervisor]
    Supervisor.start_link(children, opts)
end
```

For now, we will not focus on the Application behaviour, just on the fact that the start callback needs to return `{:ok, pid}` from a linked supervisor.

In order to start the Supervisor, we see that children are necessary. As the comments indicate, let's try to just uncomment the line and replace the necessary parts.

```elixir
children = [ {SampleProject.Demo, []} ]
```

When running the application, we get the following error:

```text
(ArgumentError) The module SampleProject.Demo was given as a child to a supervisor
but it does not implement child_spec/1.
```

If you own the given module, please define a child_spec/1 function
that receives an argument and returns a child specification as a map.

However, if you don't own the given module and it doesn't implement
child_spec/1, instead of passing the module name directly as a supervisor
child, you will have to pass a child specification as a map:

```elixir
%{
  id: SampleProject.Demo,
  start: {SampleProject.Demo, :start_link, [arg1, arg2]}
}
```

Elixir is complaining because the Supervisor doesn't has enough information. In the complete error log there's more information, but we'll cover that later on. For now the error gives us 2 suggestions, well actually 3 in the complete log:

* Implement the `child_spec/1` behaviour in the given module.
* Pass the child specification as a map. (Often done when you can't/don't want to implement the function).
* The third option is to convert to a GenServer/Agent because then the code is already injected for you (though we're not considering this option).

### Pass child specs as a map

Let's quickly go over the three necessary parts of info that the Supervisor needs:

* How it should start the child.
* What it should do when the child terminates.
* How, or by what term, it should uniquely distinguish the child.

When we read the suggestion from the error, let us replace the important bits so that it works:

```elixir
%{
  id: :demo_id,
  start: {SampleProject.Demo, :start_link, []}
}
...
opts = [strategy: :one_for_one, name: SampleProject.Supervisor]
```

All right, the map covers how the supervisor should start the child (tuple with Module, function, arguments), what the id __specifically for the supervisor__ is and finally what it should do when the child terminates (restart strategy). We will cover restart strategies at the end of this section, for now we'll use the default ":one_for_one" strategy.

When you spin up your project, open `:observer.start` and click on the applications tab. There you can see your named process after your application-level supervisor.

_Note that the id from in the child specification is not the name that will show up in your observer. This is purely used internally, while the name passed to `Process.register` is the one constant that's used to identify the process's PID._

### Implement the child_specs function

Though the child spec map is a quick solution, let's implement this decently. For now we'll use the generated sample code:

```elixir
# Application.start function:
children = [
  {SampleProject.Demo, []}
]

# SampleProject.Demo module:
def child_spec(opts) do
    %{
    id: __MODULE__,
    start: {__MODULE__, :start_link, [opts]},
    type: :worker,
    restart: :permanent,
    shutdown: 500
    }
end
```

Now it is no longer necessary to write a relatively large map in your children array. It is concise an to the point.

In the `SampleProject.Demo` module we can see some similar data as with the previous solution, specifically the id and the start module, function and arguments. Other than that we have:

* **type** There are 2 different types of supervisable processes. Workers and Supervisors, internally they are both GenServers, but this data is important for building your supervision tree.
* **restart** This should be one of
  * permanent: The process is always restarted.
  * temporary: Regardless of the restart strategy, the process is never restarted.
  * transient: The process only restarts when it shuts down abnormally. We're not going to cover all different exit signals, but more information can be found in [the supervisor documentation](https://hexdocs.pm/elixir/Supervisor.Spec.html#module-shutdown-values-shutdown).
* **shutdown** This can be either a timeout or an atom such as `:brutal_kill` or `:infinity`. Often supervisors are configured to have `:infinity`, so that they can correctly shut down all processes. In our example, we'll give half a second to shut down.

### A customized child_spec implementation

Let's say that we want to start a process multiple times. If we'd use the above implementation, it'll give issues because 1. the id is not unique and 2. the name is already registered. Let us quickly rewrite our code so that this can be passed in our arguments.

```elixir
defmodule SampleProject.Demo do
  defmodule Args do
    @necessary [:id, :name, :args]
    def verify_has_necessary_args(args) do
      extracted_keys = Enum.map(args, fn {k, _v} -> k end)

      case Enum.all?(@necessary, &(&1 in extracted_keys)) do
        true -> :ok
        false -> raise "Should have :id, :name and :args param!"
      end
    end
  end

  def start_link(name, _args) do
    pid = spawn_link(__MODULE__, :receive_messages, [])
    Process.register(pid, name)
    {:ok, pid}
  end

  def receive_messages() ...

  def child_spec(opts) do
    Args.verify_has_necessary_args(opts)

    %{
      id: opts[:id],
      start: {__MODULE__, :start_link, [opts[:name], opts[:args]]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
```

The biggest change is the nested module for code organizational purposes. Here we define with a module attribute (`@necessary`) what the necessary arguments are. After verifying this, we use these arguments in our `child_spec/1` function for the id. The remaining arguments are passed to the `start_link` function, where we register the name as specified in the argument list. This way we can easily add extra children in our supervisor:

```elixir
    children = [
      {SampleProject.Demo, [id: :demo_id, name: :demo, args: []]},
      {SampleProject.Demo, [id: :demo_id2, name: :demo2, args: []]}
    ]
```

There are different kinds of supervisors, some examples would be:

* Dynamic supervisor
* Task supervisor

It is often said that the normal supervisor is perfect when you know from the start how much processes it will have to supervise. In comparison with the dynamic supervisor, you'll add and remove processes all the time. This is also the reason why you can easily start processes under the dynamic supervisor without worrying about the :id parameter. (This is an often overlooked sentence in the [docs](https://hexdocs.pm/elixir/DynamicSupervisor.html#which_children/1), which is that the id's of the children are always `:undefined`!)

Task supervisors are different, considering the tasks it will supervise will end. In comparison with the normal supervisor, the default restart option is `:transient`. This is because Tasks are meant to be computational processes that will end and give a return value.

## Restart strategies

We've seen that the default restart strategy is `:one_for_one`. Here we'll see what this exactly means and what different strategies there are.

### One for one

This is the most straightforward strategy. Let us assume we have three processes:

```text
    A   B   C
```

Imagine that process B crashes. Then it'll detect this and restart only process B.

```text
    A   B   C
    |   |   |
    A   X   C  => B crashes
    |   |   |
    A   B'  C
```

Other processes are not influenced (directly, assuming there is no communication) by the crashed process.
_Note that process B' has no knowledge of the state of process B and starts completely fresh._

### One for all

If you have processes which depend on each other, then it might be necessary to restart all your processes under your supervisor.

```text
    A   B   C
    |   |   |
    A   X   C  => B crashes
    |   |   |
    X   X   X  => All processes are killed
    |   |   |
    A'  B'  C' => All processes are restarted
```

As you can see in the above schema, when one process dies, all processes under this process are restarted.

### Rest for one

In the previous strategies, the order in which the processes were spawned were of no importance. With the rest for one example, the order in which the processes are spawned is important. Based on this, different processes will be restarted.

Let us compare 2 scenarios where the processes are spawned in the following order: A &rarr; B &rarr; C.

#### Scenario 1: Process C crashes

```text
    A   B   C
    |   |   |
    A   B   X  => C crashes
    |   |   |
    A   B   C' => C is restarted
```

Process C is the last process that was started. Because there are no processes which were started after C, only C restarts.

#### Scenario 2: Process B crashes

```text
    A   B   C
    |   |   |
    A   X   C  => B crashes
    |   |   |
    A   X   X  => All processes after B, in this case only C, are killed as well
    |   |   |
    A   B'  C' => B and C are restarted in the same order
```

Here we can see that when B crashes, C is restarted as well. Which results in 2 restarted processes B' and C', which have the same order as before.
