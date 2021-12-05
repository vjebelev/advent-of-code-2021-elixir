defmodule Hydro do
  # horizontal lines
  def points([x1, y1], [x2, y2]) when y1 == y2 and x1 <= x2, do: Enum.map(x1..x2, &[&1, y1])
  def points([x1, y1], [x2, y2]) when y1 == y2 and x1 > x2, do: Enum.map(x2..x1, &[&1, y1])

  # vertical lines
  def points([x1, y1], [x2, y2]) when x1 == x2 and y1 <= y2, do: Enum.map(y1..y2, &[x1, &1])
  def points([x1, y1], [x2, y2]) when x1 == x2 and y1 > y2, do: Enum.map(y2..y1, &[x1, &1])

  # diagonal lines
  def points([x1, y1], [x2, y2]) when x1 < x2 and y1 < y2 and (x2 - x1) == (y2 - y1) do
    Enum.map(x1..x2, &[&1, y1 + (&1 - x1)])
  end

  def points([x1, y1], [x2, y2]) when x1 < x2 and y1 > y2 and (x2 - x1) == (y1 - y2) do
    Enum.map(x1..x2, &[&1, y2 + (x2 - &1)])
  end

  def points([x1, y1], [x2, y2]) when x1 > x2 and y1 < y2 and (x1 - x2) == (y2 - y1) do
    Enum.map(x1..x2, &[&1, y1 + (x1 - &1)])
  end

  def points([x1, y1], [x2, y2]) when x1 > x2 and y1 > y2 and (x1 - x2) == (y1 - y2) do
    Enum.map(x1..x2, &[&1, y2 + (&1 - x2)])
  end

  def points(_, _), do: []
end

points =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    Regex.named_captures(~r/(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/, line)
  end)
  |> Enum.reduce(%{}, fn line, acc ->
    Hydro.points(
      [String.to_integer(line["x1"]), String.to_integer(line["y1"])], 
      [String.to_integer(line["x2"]), String.to_integer(line["y2"])]
    )
    |> Enum.reduce(acc, fn point, acc ->
      case Map.get(acc, point) do
        nil -> Map.put(acc, point, 1)
        num -> Map.put(acc, point, 1 + num)
      end
    end)
  end)

count = Enum.count(points, fn {_, num} -> num >= 2 end)
IO.puts "2: #{count}"
