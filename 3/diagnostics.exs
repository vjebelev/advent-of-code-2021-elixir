defmodule Diagnostics do
  def binary_string_to_decimal(str), do: Integer.parse(str, 2) |> elem(0)

  def gamma_rate(numbers) do
    numbers
    |> calculate_frequencies()
    |> rate(&(elem(&1, 1) > elem(&2, 1)))
  end

  def epsilon_rate(numbers) do
    numbers
    |> calculate_frequencies()
    |> rate(&(elem(&1, 1) < elem(&2, 1)))
  end

  def oxygen_generator_rating(numbers) do
    numbers
    |> rating(&{elem(&1, 1), elem(&1, 0)}, &>=/2)
  end

  def co2_scrubber_rating(numbers) do
    numbers
    |> rating(&{elem(&1, 1), elem(&1, 0)}, &<=/2)
  end

  defp empty_frequencies(n), do: Map.new(1..n, fn x -> {x, %{"0" => 0, "1" => 0}} end)

  defp fetch_bit(number, i), do: number |> String.codepoints() |> Enum.at(i)

  defp calculate_frequencies(numbers) do
    numbers
    |> Enum.reduce(
      empty_frequencies(String.length(List.first(numbers))),
      fn number, acc ->
        updated_frequencies(number, acc)
      end
    )
  end

  defp updated_frequencies(number, frequencies) do
    bits = String.codepoints(number)

    1..length(bits)
    |> Enum.reduce(frequencies, fn i, acc ->
      Map.update(acc, i, nil, fn freq ->
        bit = Enum.at(bits, i - 1)
        Map.put(freq, bit, 1 + Map.get(freq, bit))
      end)
    end)
  end

  defp rate(frequencies, sorter_fx) do
    frequencies
    |> Map.keys()
    |> Enum.map(fn x ->
      frequencies
      |> Map.get(x)
      |> Enum.sort(sorter_fx)
      |> List.first()
      |> elem(0)
    end)
    |> Enum.join()
  end

  defp rating(numbers, mapper_fx, sorter_fx) do
    1..String.length(Enum.at(numbers, 0))
    |> Enum.reduce(numbers, fn i, acc ->
      case acc do
        [_] ->
          acc

        _ ->
          frequencies = calculate_frequencies(acc)

          Enum.reject(acc, fn number ->
            bit = fetch_bit(number, i - 1)

            bit_criteria =
              Map.get(frequencies, i)
              |> Enum.sort_by(mapper_fx, sorter_fx)
              |> List.first()
              |> elem(0)

            bit != bit_criteria
          end)
      end
    end)
    |> Enum.at(0)
  end
end

numbers =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)

gamma = Diagnostics.gamma_rate(numbers)
decimal_gamma = Diagnostics.binary_string_to_decimal(gamma)

epsilon = Diagnostics.epsilon_rate(numbers)
decimal_epsilon = Diagnostics.binary_string_to_decimal(epsilon)
IO.puts("1: #{decimal_gamma * decimal_epsilon}")

oxygen_rating = Diagnostics.oxygen_generator_rating(numbers)
decimal_oxygen_rating = Diagnostics.binary_string_to_decimal(oxygen_rating)

co2_rating = Diagnostics.co2_scrubber_rating(numbers)
decimal_co2_rating = Diagnostics.binary_string_to_decimal(co2_rating)
IO.puts("2: #{decimal_oxygen_rating * decimal_co2_rating}")
