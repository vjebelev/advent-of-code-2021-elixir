defmodule Syntax do
  def error_score(s) when s == ")", do: 3
  def error_score(s) when s == "]", do: 57
  def error_score(s) when s == "}", do: 1197
  def error_score(s) when s == ">", do: 25137

  def valid?(str) when is_binary(str) do
    line_error_score(str) == 0
  end

  def paren_match?(opening, closing) do
    case {opening, closing} do
      {"(", ")"} -> true
      {"[", "]"} -> true
      {"{", "}"} -> true
      {"<", ">"} -> true
      _ -> false
    end
  end

  def line_error_score(line) do
    line
    |> String.codepoints()
    |> Enum.reduce_while({0, ""}, fn x, {_, str} ->
      case x do
        x when x in ["(", "[", "{", "<"] ->
          {:cont, {0, Enum.join([str, x])}}

        x when x in [")", "]", "}", ">"] ->
          last_character = String.at(str, String.length(str) - 1)
          if paren_match?(last_character, x) do
            {:cont, {0, String.slice(str, 0, String.length(str) - 1)}}
          else
            {:halt, {error_score(x), str}}
          end
      end
    end)
    |> elem(0)
  end

  def remove_pairs(line) do
    line
    |> String.codepoints()
    |> Enum.reduce_while(line, fn _, acc ->
      if Regex.match?(~r/\(\)|\[\]|\{\}|\<\>/, acc) do
        acc =
          acc
          |> String.replace("()", "")
          |> String.replace("[]", "")
          |> String.replace("{}", "")
          |> String.replace("<>", "")

        {:cont, acc}
      else
        {:halt, acc}
      end
    end)
  end

  def completion_line(line) do
    line
    |> remove_pairs()
    |> String.replace("(", ")")
    |> String.replace("[", "]")
    |> String.replace("{", "}")
    |> String.replace("<", ">")
    |> String.reverse()
  end

  def completion_score(s) when s == ")", do: 1
  def completion_score(s) when s == "]", do: 2
  def completion_score(s) when s == "}", do: 3
  def completion_score(s) when s == ">", do: 4

  def line_completion_score(line) do
    line
    |> String.codepoints()
    |> Enum.reduce(0, fn x, acc ->
      5 * acc + completion_score(x)
    end)
  end
end

lines =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)

error_score =
  lines
  |> Enum.reject(&(Syntax.valid?(&1)))
  |> Enum.map(&Syntax.line_error_score(&1))
  |> Enum.sum()

IO.puts "1: #{error_score}"

completion_scores =
  lines
  |> Enum.filter(&(Syntax.valid?(&1)))
  |> Enum.map(&(Syntax.completion_line(&1)))
  |> Enum.map(&(Syntax.line_completion_score(&1)))
  |> Enum.sort()

middle_score =
  Enum.at(completion_scores, div(length(completion_scores), 2))

IO.puts "2: #{inspect(middle_score)}"
