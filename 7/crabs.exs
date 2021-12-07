positions =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn x -> String.split(x, ",", trim: true) end )
  |> List.flatten()
  |> Enum.map(&String.to_integer/1)

min = Enum.min(positions)
max = Enum.max(positions)

moves =
  for i <- min..max do
    positions
    |> Enum.map(fn x -> abs(x - i) end)
    |> Enum.sum()
  end

min_fuel = Enum.min(moves)
IO.puts "1: #{min_fuel}"

add_fuel_fn = fn (fuel) -> div(fuel * (fuel + 1), 2) end

moves =
  for i <- min..max do
    positions
    |> Enum.map(fn x ->
      n = abs(x - i)
      n + add_fuel_fn.(n - 1)
    end)
    |> Enum.sum()
  end

min_fuel = Enum.min(moves)
IO.puts "2: #{min_fuel}"
