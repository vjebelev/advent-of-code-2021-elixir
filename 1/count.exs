depths =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

count =
  depths
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn [a, b] -> b - a end)
  |> Enum.filter(fn x -> x > 0 end)
  |> Enum.count()

IO.puts "1: #{count}"

count =
  depths
  |> Enum.chunk_every(3, 1, :discard)
  |> Enum.map(&Enum.sum/1)
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn [a, b] -> b - a end)
  |> Enum.filter(fn x -> x > 0 end)
  |> Enum.count()
  
IO.puts "2: #{count}"
