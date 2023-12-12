defmodule AdventOfCode.Day02 do
  def part1(input) do
    {:ok, parsed, _, _, _, _} = __MODULE__.Parser.input(input)

    parsed
    |> Enum.map(fn [index: idx, hands: hands] ->
      {idx, Enum.all?(hands, &part1_valid_hand?/1)}
    end)
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(&+/2)
  end

  def part1_valid_hand?(%{red: red, green: green, blue: blue}) do
    red <= 12 and green <= 13 and blue <= 14
  end

  defmodule Parser do
    import NimbleParsec

    handful =
      wrap(
        times(
          lookahead_not(ascii_char([?\n, ?;]))
          |> ignore(optional(string(",")) |> string(" "))
          |> integer(min: 1)
          |> ignore(string(" "))
          |> choice([
            replace(string("red"), :red),
            replace(string("green"), :green),
            replace(string("blue"), :blue)
          ]),
          min: 1
        )
      )
      |> map(:normalize_handful)

    defp normalize_handful(handful) do
      normalize_handful(handful, nil, %{red: 0, green: 0, blue: 0})
    end

    defp normalize_handful([], _, acc) do
      acc
    end

    defp normalize_handful([val | rest], nil, acc) do
      normalize_handful(rest, val, acc)
    end

    defp normalize_handful([key | rest], val, acc) do
      normalize_handful(rest, nil, Map.update!(acc, key, &(&1 + val)))
    end

    game =
      ignore(string("Game "))
      |> unwrap_and_tag(integer(min: 1), :index)
      |> ignore(string(":"))
      |> tag(
        times(
          lookahead_not(ascii_char([?\n]))
          |> ignore(optional(string(";")))
          |> concat(handful),
          min: 1
        ),
        :hands
      )

    defparsec(
      :input,
      repeat(
        ignore(optional(string("\n")))
        |> wrap(game)
      )
      |> ignore(optional(string("\n")))
      |> eos()
    )

    defparsec(:game_p, game)

    defparsec(:handful_p, handful)
  end

  def part2(input) do
    {:ok, parsed, _, _, _, _} = __MODULE__.Parser.input(input)

    parsed
    |> Enum.map(fn [index: _idx, hands: hands] ->
      power(hands)
    end)
    |> Enum.reduce(&+/2)
  end

  def power(hands) do
    %{red: red, green: green, blue: blue} =
      Enum.reduce(
        hands,
        %{red: 0, green: 0, blue: 0},
        fn
          %{red: red1, green: green1, blue: blue1}, %{red: red2, green: green2, blue: blue2} ->
            %{red: max(red1, red2), green: max(green1, green2), blue: max(blue1, blue2)}
        end
      )

    red * green * blue
  end
end
