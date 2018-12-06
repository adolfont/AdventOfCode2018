defmodule InventoryManagementSystem do
  # Creates a map with the frequency of each letter in a list of chacacters
  def create_frequency_map([], map) do
    map
  end

  def create_frequency_map([head | tail], map) do
    create_frequency_map(tail, Map.update(map, head, 1, fn x -> x + 1 end))
  end

  # Returns a pair where 
  # the first element is true if there is at least one character that happens exactly thrice in string
  # the second element is true if there is at least one character that happens exactly twice in string
  def thrice_twice_occurences(string) do
    values =
      String.codepoints(string)
      |> Enum.sort()
      |> create_frequency_map(Map.new())
      |> Map.values()

    {3 in values, 2 in values}
  end

  def calculate_cheksum(filename) do
    {x, y} =
      File.stream!(filename, [], :line)
      |> process_file()

    x * y
  end

  defp process_file_aux(n_threes, n_twos, []) do
    {n_threes, n_twos}
  end

  defp process_file_aux(o_threes, o_twos, stream) do
    [string] = Enum.take(stream, 1)
    {threes, twos} = thrice_twice_occurences(string)
    n_threes = if threes, do: 1, else: 0
    n_twos = if twos, do: 1, else: 0
    process_file_aux(n_threes + o_threes, n_twos + o_twos, Enum.drop(stream, 1))
  end

  # processes a file to finds occurrences of repeated characters 
  defp process_file(stream) do
    process_file_aux(0, 0, stream)
  end

  ### PART 2

  # auxiliar function that does the hard work of differ_by_exactly_one_character
  defp aux_differ(false, _, "", "") do
    {false, -1}
  end

  defp aux_differ(true, y, "", "") do
    {true, y}
  end

  defp aux_differ(false, y, s1, s2) do
    if String.at(s1, 0) != String.at(s2, 0) do
      aux_differ(true, y, String.slice(s1, 1..-1), String.slice(s2, 1..-1))
    else
      aux_differ(false, y + 1, String.slice(s1, 1..-1), String.slice(s2, 1..-1))
    end
  end

  defp aux_differ(true, y, s1, s2) do
    if String.at(s1, 0) != String.at(s2, 0) do
      {false, -1}
    else
      aux_differ(true, y, String.slice(s1, 1..-1), String.slice(s2, 1..-1))
    end
  end

  # verifies of two strings of teh same length differ by exactly one character and where
  # returns {true, position} if the strings differ by exactly one character where "position" is the different character 
  # returns {false, -1} if the strings differ by more than one character or are equal or are not of the same length  
  def differ_by_exactly_one_character(string1, string2) do
    if String.length(string1) != String.length(string2) do
      {false, -1}
    else
      aux_differ(false, 0, string1, string2)
    end
  end

  def new_string_removing_one_character(string, position) do
    String.slice(string, 0..(position - 1)) <> String.slice(string, (position + 1)..-1)
  end

  def process_file_differ([]) do
    nil
  end

  def process_file_differ([head | tail]) do
    result =
      Enum.find(tail, fn x ->
        {a, _} = differ_by_exactly_one_character(head, x)
        a
      end)

    if result != nil do
      {_, position} = differ_by_exactly_one_character(head, result)
      new_string_removing_one_character(head, position)
    else
      process_file_differ(tail)
    end
  end
end

defmodule Main do
  def run_tests() do
    ExUnit.start()

    defmodule InventoryManagementSystemTest do
      use ExUnit.Case

      test "No character appears two or three times" do
        assert InventoryManagementSystem.thrice_twice_occurences("abcdef") == {false, false}
        assert InventoryManagementSystem.thrice_twice_occurences("") == {false, false}
      end

      test "Three a's and three b's but no character appears two times" do
        assert InventoryManagementSystem.thrice_twice_occurences("ababab") == {true, false}
      end

      test "Two a's and two b's but no character appears three times" do
        assert InventoryManagementSystem.thrice_twice_occurences("acbadb") == {false, true}
      end

      test "Two a's and three b's" do
        assert InventoryManagementSystem.thrice_twice_occurences("acbadbnb") == {true, true}
      end

      test "Calculate checksum for a given file" do
        assert InventoryManagementSystem.calculate_cheksum("input") == 8398
      end

      test "Strings that  differ by exactly one character" do
        assert InventoryManagementSystem.differ_by_exactly_one_character("abc", "abd") ==
                 {true, 2}

        assert InventoryManagementSystem.differ_by_exactly_one_character("abcd", "abce") ==
                 {true, 3}

        assert InventoryManagementSystem.differ_by_exactly_one_character("abcdfgh", "abcefgh") ==
                 {true, 3}

        assert InventoryManagementSystem.differ_by_exactly_one_character("bcdfgh", "bcefgh") ==
                 {true, 2}

        assert InventoryManagementSystem.differ_by_exactly_one_character("cdfgh", "cefgh") ==
                 {true, 1}

        assert InventoryManagementSystem.differ_by_exactly_one_character("dfgh", "efgh") ==
                 {true, 0}
      end

      test "Strings that do not differ by exactly one character" do
        assert InventoryManagementSystem.differ_by_exactly_one_character("abcc", "abdd") ==
                 {false, -1}

        assert InventoryManagementSystem.differ_by_exactly_one_character("abcc", "abcc") ==
                 {false, -1}

        assert InventoryManagementSystem.differ_by_exactly_one_character("abc", "abcd") ==
                 {false, -1}

        assert InventoryManagementSystem.differ_by_exactly_one_character("abc", "abcddfsgsdgf") ==
                 {false, -1}
      end

      test "String created by removing one character" do
        assert InventoryManagementSystem.new_string_removing_one_character("abcxdef", 3) ==
                 "abcdef"
      end

      test "Find string for a given file" do
        {:ok, file} = File.read("input")

        assert InventoryManagementSystem.process_file_differ(String.split(file, "\n")) ==
                 "hhvsdkatysmiqjxunezgwcdpr"
      end
    end
  end
end

Main.run_tests()
