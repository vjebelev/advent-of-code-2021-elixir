defmodule Flashes do
  defstruct grid: %{}, flashes: %{}, num_flashed: 0

  # ["12", "34"] -> %{[0,0] => 1, [0,1] => 3, [1,0] => 2, [1,1] => 4}
  def new(lines) do
    %__MODULE__{
      grid:
        lines
        |> Enum.with_index()
        |> Enum.map(fn {line, y} ->
          line
          |> String.codepoints()
          |> Enum.map(&String.to_integer/1)
          |> Enum.with_index()
          |> Enum.map(fn {digit, x} -> {[x, y], digit} end)
        end)
        |> List.flatten()
        |> Enum.into(%{})
    }
  end

  def value(%__MODULE__{grid: grid}, [_x, _y] = coord) do
    Map.get(grid, coord)
  end

  def max_x(%__MODULE__{grid: grid}) do
    grid
    |> Map.keys()
    |> Enum.max_by(fn [x, _] -> x end)
    |> Enum.at(0)
  end

  def max_y(%__MODULE__{grid: grid}) do
    grid
    |> Map.keys()
    |> Enum.max_by(fn [_, y] -> y end)
    |> Enum.at(1)
  end

  def adjacent(%__MODULE__{grid: grid}, [x, y]) do
    for x_adj <- -1..1,
        y_adj <- -1..1,
        x_adj * y_adj + x_adj + y_adj != 0,
        Map.has_key?(grid, [x + x_adj, y + y_adj]) do
      [x + x_adj, y + y_adj]
    end
  end

  def flash_coords(%__MODULE__{} = map) do
    for x <- 0..max_x(map), y <- 0..max_y(map), value(map, [x, y]) > 9 , do: [x, y]
  end

  def set_value(%__MODULE__{grid: grid} = map, [_x, _y] = coord, value) do
    %{map | grid: Map.put(grid, coord, value)}
  end

  def add_flash_point(%__MODULE__{flashes: flashes} = map, [_x, _y] = coord) do
    %{map | flashes: Map.put(flashes, coord, true)}
  end

  def reset_flashes(%__MODULE__{} = map) do
    %{map | flashes: %{}}
  end

  def already_flashed?(%__MODULE__{flashes: flashes}, [_x, _y] = coord) do
    Map.has_key?(flashes, coord)
  end

  def up_num_flashed(%__MODULE__{num_flashed: num_flashed} = map) do
    %{map | num_flashed: 1 + num_flashed}
  end

  def drain_cell(%__MODULE__{} = map, [_x, _y] = coord) do
    map
    |> set_value(coord, 0)
    |> add_flash_point(coord)
    |> up_num_flashed()
  end

  def inc(%__MODULE__{} = map) do
    grid =
      for x <- 0..max_x(map), y <- 0..max_y(map) do
        {[x, y], 1 + value(map, [x, y])}
      end
      |> Enum.into(%{})

    %{map | grid: grid}
  end

  def flash(%__MODULE__{} = map) do
    map
    |> flash_coords()
    |> Enum.reduce_while(map, fn coord, acc ->
      acc = drain_cell(acc, coord)

      updated_map = 
        acc
        |> adjacent(coord)
        |> Enum.reject(fn adj_coord -> already_flashed?(acc, adj_coord) end)
        |> Enum.reduce(acc, fn adj_coord, aj_acc ->
          set_value(aj_acc, adj_coord, 1 + value(aj_acc, adj_coord))
        end)

      case flash_coords(updated_map) do
        [] -> {:halt, updated_map}
        _ -> {:cont, updated_map}
      end
    end)
  end

  # This is a step.
  def advance(%__MODULE__{} = map) do
    map =
      map
      |> reset_flashes()
      |> inc()

    Enum.reduce_while(1..100, map, fn _, acc ->
      acc = flash(acc)
      case flash_coords(acc) do
        [] -> {:halt, acc}
        _ -> {:cont, acc}
      end
    end)
  end

  def sim_flash?(%__MODULE__{flashes: flashes} = map) do
    map_size(flashes) == (1 + max_x(map)) * (1 + max_y(map))
  end
end

matrix =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Flashes.new()

no_steps = 100
new_matrix = 
  1..no_steps
  |> Enum.reduce(matrix, fn _, acc ->
    Flashes.advance(acc)
  end)

IO.puts "1: #{new_matrix.num_flashed}"

{step_no, _} =
  1..1000
  |> Enum.reduce_while({0, matrix}, fn x, {_, acc} ->
    acc = Flashes.advance(acc)
    case Flashes.sim_flash?(acc) do
      true -> {:halt, {x, acc}}
      false -> {:cont, {x, acc}}
    end
  end)

IO.puts "2: #{step_no}"
