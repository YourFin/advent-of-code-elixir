defmodule AdventOfCode.Day01 do
  def part1(input) do
    part1(0, nil, input)
  end

  defp part1(running_sum, nil, <<0::0>>) do
    running_sum
  end

  defp part1(running_sum, val, <<0::0>>) do
    running_sum + val
  end

  defp part1(running_sum, nil, <<?\n, rest::binary>>) do
    part1(running_sum, nil, rest)
  end

  defp part1(running_sum, val, <<?\n, rest::binary>>) do
    part1(running_sum + val, nil, rest)
  end

  defp part1(running_sum, val, <<char, rest::binary>>) do
    case intValueOf(char) do
      nil ->
        part1(running_sum, val, rest)

      int ->
        part1(
          case val do
            nil -> running_sum + int * 10
            _ -> running_sum
          end,
          int,
          rest
        )
    end
  end

  # Note: ?char -> turn char into asci character code int
  defp intValueOf(char) when ?0 <= char and char <= ?9 do
    char - ?0
  end

  defp intValueOf(_) do
    nil
  end

  def part2(input) do
    part2(0, nil, input)
  end

  # "lazy" way of building a large prefix parse table for this problem.
  # It is also, as I have come to learn, a shitty thing to use a macro for.
  #
  # Notably because clauses /must/ be a literal. One is tempted to attempt
  # something like:
  #   Enum.map(Range.of(0, 9), fn val -> {?0 + val, val})
  # as an argument to build a parse table from ?0 -> 0, ?1 -> 1, etc.
  # I /think/ this would require comptime/constexpr ala zig/c++, however,
  # which I don't think there's an equivalent for here.
  #
  # The "smart" way of doing this would probably have just been making this an
  # arity-0 macro purpose-built for this specific case.
  #
  # See the final head of part2/3 for use
  defmacrop pop_table(clauses) do
    quote do
      fn input ->
        case input do
          unquote(
            Enum.flat_map(clauses, &pop_table_clause/1) ++
              [
                case_clause(
                  quote(do: <<_::size(8), rest::binary>>),
                  quote(do: {nil, rest})
                )
              ]
          )
        end
      end
    end
  end

  defp pop_table_clause({:{}, _, [binaryPrefix1, binaryPrefix2, associatedValue]}) do
    [
      case_clause(
        quote(do: <<unquote(binaryPrefix1), rest::binary>>),
        quote(do: {unquote(associatedValue), rest})
      ),
      case_clause(
        quote(do: <<unquote(binaryPrefix2), rest::binary>>),
        quote(do: {unquote(associatedValue), rest})
      )
    ]
  end

  defp case_clause(lhs, rhs) do
    {:->, [], [[lhs], rhs]}
  end

  defp part2(running_sum, nil, <<0::0>>) do
    running_sum
  end

  defp part2(running_sum, val, <<0::0>>) do
    running_sum + val
  end

  defp part2(running_sum, nil, <<?\n, rest::binary>>) do
    part2(running_sum, nil, rest)
  end

  defp part2(running_sum, val, <<?\n, rest::binary>>) do
    part2(running_sum + val, nil, rest)
  end

  defp part2(running_sum, val, bin) do
    case pop_table([
           {"zero", ?0, 0},
           {"one", ?1, 1},
           {"two", ?2, 2},
           {"three", ?3, 3},
           {"four", ?4, 4},
           {"five", ?5, 5},
           {"six", ?6, 6},
           {"seven", ?7, 7},
           {"eight", ?8, 8},
           {"nine", ?9, 9}
         ]).(bin) do
      {nil, rest} ->
        part2(running_sum, val, rest)

      {int, rest} ->
        part2(
          case val do
            nil -> running_sum + int * 10
            _ -> running_sum
          end,
          int,
          rest
        )
    end
  end
end
