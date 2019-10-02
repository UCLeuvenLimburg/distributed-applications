defp threadproc do
  IO.puts("Runs in different process")
end

spawn(&threadproc/0)
