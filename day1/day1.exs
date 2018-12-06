defmodule Advent1 do
  defp process(value, already, [], original) do
    process(value, already, original, original)
  end

  defp process(value, already, [head | tail], original) do
    if value in already do
      value
    else
      process(value + String.to_integer(head), [value | already], tail, original)
    end
  end

  def do_it(filename) do
    {:ok, file} = File.read(filename)
    list = String.split(file, "\n")
    process(0, [], list, list)
  end
end

IO.puts(Advent1.do_it("input"))
