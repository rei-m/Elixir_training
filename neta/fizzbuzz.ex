defmodule FizzBuzz do
  def fizz_buzz_1(n) do
    Enum.map_join 1..n, fn x ->
      cond do
        rem(x, 15) === 0 ->
          "FizzBuzz"
        rem(x, 3) === 0 ->
          "Fizz"
        rem(x, 5) === 0 ->
          "Buzz"
        true ->
          x
      end
    end
  end

  defp fizzbuzz do
    fn
      {true, true}   -> "FizzBuzz"
      {true, false}  -> "Fizz"
      {false, true}  -> "Buzz"
      {false, false} -> nil
    end
  end

  def fizz_buzz_2(cnt) do
    1..cnt |> Enum.map_join fn(n) ->
      case fizzbuzz.({rem(n, 3) === 0, rem(n, 5) === 0}) do
        nil -> n
        s -> s
      end
    end
  end
end

IO.inspect FizzBuzz.fizz_buzz_1(30)
IO.inspect FizzBuzz.fizz_buzz_2(30)
