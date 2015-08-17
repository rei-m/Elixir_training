defmodule FizzBuzz do
  def fizz_buzz(n) do
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
end

IO.inspect FizzBuzz.fizz_buzz(100)
