# defmodule MyGenServer do
#   use GenServer

#   ##########
#   #  API   #
#   ##########
#   def start(args), do: GenServer.start(__MODULE__, args, name: __MODULE__)
#   def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

#   ##########
#   # SERVER #
#   ##########
#   def init(init_arg), do: {:ok, init_arg}
# end

# defmodule TaskHandler do
#   use GenServer

#   defmodule TaskHandler.State do
#     @enforce_keys [:task_limit]
#     defstruct [:task_limit, tasks: []]
#   end

#   def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)
#   def init(args), do: {:ok, struct!(TaskHandler.State, args)}
# end

# args_to_be_passed = [a: :value, b: :another_value]
# TaskHandler.start_link(args_to_be_passed)

defmodule TaskHandler do
  use GenServer
  @check_time 100
  defstruct task_limit: 2, tasks: [], queue: []

  ##########
  # CLIENT #
  ##########
  def start_link(args \\ []),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def status(),
    do: GenServer.call(__MODULE__, :status)

  def add_task(func) when is_function(func),
    do: GenServer.cast(__MODULE__, {:add, func})

  ##########
  # SERVER #
  ##########
  def init(args),
    do: {:ok, struct(TaskHandler, args), {:continue, :start_recurring_tasks}}

  def handle_cast({:add, fun}, %{tasks: t, queue: q, task_limit: tl} = s)
      when length(t) >= tl,
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
      {_, []} ->
        {:noreply, s}

      {alive, _fin} ->
        {:noreply, %{s | tasks: [spawn(first_fun) | alive], queue: rest}}
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
