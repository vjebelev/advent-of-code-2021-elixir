defmodule Digits do
  def wires_for_digit(digit) do
    case digit do
      0 -> "abcefg"
      1 -> "cf"
      2 -> "acdeg"
      3 -> "acdfg"
      4 -> "bcdf"
      5 -> "abdfg"
      6 -> "abdefg"
      7 -> "acf"
      8 -> "abcdefg"
      9 -> "abcdfg"
    end
    |> String.codepoints()
  end

  def number_for_wires(wires) do
    case wires do
      "abcefg" -> 0
      "cf" -> 1
      "acdeg" -> 2
      "acdfg" -> 3
      "bcdf" -> 4
      "abdfg" -> 5
      "abdefg" -> 6
      "acf" -> 7
      "abcdefg" -> 8
      "abcdfg" -> 9
    end
  end

  def patterns_by_length(patterns, length) do
    Enum.filter(patterns, fn x -> String.length(x) == length end)
  end

  def wires_for_length(patterns, len) do
    patterns
    |> patterns_by_length(len)
    |> Enum.at(0)
    |> String.codepoints()
  end

  def letter_frequency(patterns, letter) do
    Enum.count(patterns, &(String.contains?(&1, letter)))
  end

  # Difference between 2 and 3-letter patterns (1 and 7 digits) is the wire for 'a'.
  def wire_for("a", patterns) do
    (String.codepoints(Enum.at(patterns_by_length(patterns, 3), 0)) -- 
      String.codepoints(Enum.at(patterns_by_length(patterns, 2), 0)))
      |> Enum.at(0)
  end

  # Wires for 4 without wires for 1 and then choose based on frequency in inputs
  def wire_for("b", patterns) do
    wires =
      wires_for_length(patterns, 4) -- (wires_for_digit(1) |> Enum.map(&(wire_for(&1, patterns))))
    
    case letter_frequency(patterns, Enum.at(wires, 0)) do
      6 -> Enum.at(wires, 0)
      7 -> Enum.at(wires, 1)
    end
  end

  def wire_for("c", patterns) do
    wires = patterns_by_length(patterns, 2) |> Enum.at(0) |> String.codepoints()

    case letter_frequency(patterns, Enum.at(wires, 0)) do
      8 -> Enum.at(wires, 0)
      9 -> Enum.at(wires, 1)
    end
  end

  def wire_for("d", patterns) do
    wires =
      wires_for_length(patterns, 4) -- (wires_for_digit(1) |> Enum.map(&(wire_for(&1, patterns))))
    
    case letter_frequency(patterns, Enum.at(wires, 0)) do
      6 -> Enum.at(wires, 1)
      7 -> Enum.at(wires, 0)
    end
  end

  def wire_for("f", patterns) do
    wires = patterns_by_length(patterns, 2) |> Enum.at(0) |> String.codepoints()

    case letter_frequency(patterns, Enum.at(wires, 0)) do
      8 -> Enum.at(wires, 1)
      9 -> Enum.at(wires, 0)
    end
  end

  def wire_for("e", patterns) do
    patterns_of_6 = patterns_by_length(patterns, 6)
    known_wires = ~w(a b c d f) |> Enum.map(&(wire_for(&1, patterns)))

    wires = 
      patterns_of_6
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(fn list -> list -- known_wires end)
      |> List.flatten()
      |> Enum.uniq()
    
    case letter_frequency(patterns_of_6, Enum.at(wires, 0)) do
      2 -> Enum.at(wires, 0)
      3 -> Enum.at(wires, 1)
    end
  end

  def wire_for("g", patterns) do
    known_wires =
      ~w(a b c d f e)
      |> Enum.map(&(wire_for(&1, patterns)))

    ~w(a b c d e f g) -- known_wires
    |>Enum.at(0)
  end

  def segment_map(patterns) do
    %{
      wire_for("a", patterns) => "a",
      wire_for("b", patterns) => "b",
      wire_for("c", patterns) => "c",
      wire_for("d", patterns) => "d",
      wire_for("e", patterns) => "e",
      wire_for("f", patterns) => "f",
      wire_for("g", patterns) => "g"
    }
  end

  def wires_for_pattern(pattern, segment_map) do
    pattern
    |> String.codepoints()
    |> Enum.map(fn x -> Map.get(segment_map, x) end)
    |> Enum.sort()
    |> Enum.join()
  end

  def decode(pattern, segment_map) do
    case String.length(pattern) do
      2 -> 1
      3 -> 7
      4 -> 4
      7 -> 8
      _ -> number_for_wires(wires_for_pattern(pattern, segment_map))
    end
  end
end

lines =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, " | ", trim: true) end)
  |> List.flatten()
  |> Enum.chunk_every(2, 2)

count =
  lines
  |> Enum.map(fn [_, b] ->
    String.split(b, " ", trim: true)
    |> Enum.count(&(Enum.member?([2,3,4,7], String.length(&1))))
  end)
  |> Enum.sum()

IO.puts "1: #{count}"

count =
  lines
  |> Enum.map(fn [a, b] ->
    input = String.split(a, " ", trim: true)
    segment_map = Digits.segment_map(input)

    b
    |> String.split(" ", trim: true)
    |> Enum.map(&(Digits.decode(&1, segment_map) |> Integer.to_string()))
    |> Enum.join()
  end)
  |> Enum.map(&String.to_integer/1)
  |> Enum.sum()

IO.puts "2: #{count}"
