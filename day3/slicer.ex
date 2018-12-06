defmodule Slicer do
  @moduledoc """
  Advent of Code 2018 - Day 3
  """

  def parse(string) do
    String.split(string, ["#", " ", "@", ",", "x", ":", "\n"], trim: true)
  end

  def make_claim(string) do
    [id, left, top, width, height] = Enum.map(parse(string), &String.to_integer/1)
    [id: id, left: left, top: top, width: width, height: height]
  end

  def print_claim(line) do
    make_claim(line)
  end

  def all_claims(filename) do
    file = File.stream!(filename, [], :line)

    Enum.map(file, &print_claim/1)
  end

  def all_intersections(filename) do
    for i <- all_claims(filename) do
      make_interval(i)
    end
  end

  def make_interval(claim) do
    [
      x1: claim[:left] + 1,
      y1: claim[:top] + 1,
      x2: claim[:left] + claim[:width],
      y2: claim[:top] + claim[:height]
    ]
  end

  def interval_intersection(interval_1, interval_2) do
    x1 = max(interval_1[:x1], interval_2[:x1])
    y1 = max(interval_1[:y1], interval_2[:y1])
    x2 = min(interval_1[:x2], interval_2[:x2])
    y2 = min(interval_1[:y2], interval_2[:y2])

    if x1 <= x2 and y1 <= y2 do
      [x1: x1, y1: y1, x2: x2, y2: y2]
    else
      nil
    end
  end

  defp make_all_interval_intersections_aux([], current), do: current

  defp make_all_interval_intersections_aux([head | tail], current) do
    new =
      for i <- tail do
        interval_intersection(head, i)
      end

    make_all_interval_intersections_aux(tail, new ++ current)
  end

  def make_all_interval_intersections(list) do
    make_all_interval_intersections_aux(list, [])
    |> Enum.reject(fn x -> x == nil end)
  end

  def obtain_points(region) do
    for i <- region[:x1]..region[:x2] do
      for j <- region[:y1]..region[:y2] do
        {i, j}
      end
    end
    |> List.flatten()
  end

  def all_unique_points(list_regions) do
    Enum.map(list_regions, &obtain_points/1)
    |> List.flatten()
    |> MapSet.new()
  end

  def solve_part_1(filename) do
    Slicer.all_intersections(filename)
    |> Slicer.make_all_interval_intersections()
    |> Slicer.all_unique_points()
    |> MapSet.size()
  end
end
