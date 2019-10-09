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
