defmodule BingoBoard do
  defstruct grid: []

  def new(lines) do
    grid =
      lines
      |> Enum.map(fn x ->
        x
        |> String.split(~r{\s+}, trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
    %__MODULE__{grid: grid}
  end

  def size(%__MODULE__{grid: grid}), do: length(grid)

  def horizontals(%__MODULE__{grid: grid}), do: grid

  def verticals(%__MODULE__{grid: grid} = board) do
    Enum.map(1..size(board), fn i -> 
      Enum.map(1..size(board), fn j -> 
        Enum.at(Enum.at(grid, j - 1), i - 1) end) 
    end)
  end

  def winner?(%__MODULE__{grid: grid}, numbers) when length(numbers) < length(grid) do
    false
  end

  def winner?(%__MODULE__{} = board, numbers) do
    (horizontals(board) ++ verticals(board))
    |> Enum.any?(fn list -> 
      Enum.all?(list, fn x -> Enum.member?(numbers, x) end)
    end)
  end

  def to_list(%__MODULE__{grid: grid}) do
    Enum.reduce(grid, [], fn x, acc -> Enum.concat(acc, x) |> Enum.uniq end)
  end

  def score(%__MODULE__{} = board, numbers) do
    Enum.sum(to_list(board) -- numbers) * List.first(Enum.reverse(numbers))
  end

  def play_till_first(boards, sequence) do
    sequence
    |> Enum.reduce_while({[], []}, fn number, {_, seq} ->
      seq = [number | seq]
      winners = Enum.filter(boards, fn board -> BingoBoard.winner?(board, seq) end)

      case winners do
        [] -> {:cont, {winners, seq}}
        _ -> {:halt, {winners, Enum.reverse(seq)}}
      end
    end)
  end

  def play_till_last(boards, sequence) do
    sequence
    |> Enum.reduce_while({boards, [], []}, fn number, {remaining_boards, winners, seq} ->
      seq = [number | seq]
      new_winners = Enum.filter(remaining_boards, fn board -> BingoBoard.winner?(board, seq) end)

      acc = {remaining_boards -- new_winners, new_winners ++ winners, seq}
      case acc do
        {[], winners, sequence} -> {:halt, {winners, Enum.reverse(sequence)}}
        _ -> {:cont, acc}
      end
    end)
  end
end

[sequence_line | board_lines] =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)

sequence =
  sequence_line
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

boards = 
  board_lines
  |> Enum.chunk_every(5, 5)
  |> Enum.map(&BingoBoard.new/1)

{winners, winning_sequence} = BingoBoard.play_till_first(boards, sequence)
winner = List.first(winners)
IO.puts "1: #{BingoBoard.score(winner, winning_sequence)}"

{winners, winning_sequence} = BingoBoard.play_till_last(boards, sequence)
winner = List.first(winners)
IO.puts "2: #{BingoBoard.score(winner, winning_sequence)}"
