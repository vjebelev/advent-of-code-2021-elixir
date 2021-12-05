position =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, ~r{\s+}) end)
  |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  |> Enum.reduce({0,0}, fn {course, value}, {horiz, depth} ->
    case course do
      "forward" -> {horiz + value, depth}
      "up" -> {horiz, depth - value}
      "down" -> {horiz, depth + value}
    end
  end)

IO.puts "1: #{elem(position, 0) * elem(position, 1)}"

position =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, ~r{\s+}) end)
  |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  |> Enum.reduce({0,0,0}, fn {course, value}, {horiz, depth, aim} ->
    case course do
      "forward" -> {horiz + value, depth + aim * value, aim}
      "up" -> {horiz, depth, aim - value}
      "down" -> {horiz, depth, aim + value}
    end
  end)

IO.puts "2: #{elem(position, 0) * elem(position, 1)}"
