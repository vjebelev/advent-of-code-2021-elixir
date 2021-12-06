defmodule Lanternfish do
  defp empty_counters do
    0..8
    |> Enum.map(fn x -> {x, 0} end)
    |> Enum.into(%{})
  end

  def make_counters(fish) do
    Enum.reduce(fish, empty_counters(), fn x, acc ->
      case Map.get(acc, x) do
        nil -> Map.put(acc, x, 1)
        num -> Map.put(acc, x, 1 + num)
      end
    end)
  end

  def advance(counters, 1) do
    newborns = Map.get(counters, 0)

    %{
      0 => Map.get(counters, 1),
      1 => Map.get(counters, 2),
      2 => Map.get(counters, 3),
      3 => Map.get(counters, 4),
      4 => Map.get(counters, 5),
      5 => Map.get(counters, 6),
      6 => newborns + Map.get(counters, 7),
      7 => Map.get(counters, 8),
      8 => newborns
    }
  end

  def advance(counters, days) do
    1..days
    |> Enum.reduce(counters, fn _, acc ->
      advance(acc, 1)
    end)
  end
end

fish =
  "input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

count =
  Lanternfish.make_counters(fish)
  |> Lanternfish.advance(80)
  |> Map.values()
  |> Enum.sum()

IO.puts "1: #{count}"

count =
  Lanternfish.make_counters(fish)
  |> Lanternfish.advance(256)
  |> Map.values()
  |> Enum.sum()

IO.puts "2: #{count}"
