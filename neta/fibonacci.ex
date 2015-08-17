defmodule Fibonacci do

  # パターンマッチでフィボナッチ数列の中身を再帰的に計算
  defp fib(0) do
     0
  end

  defp fib(1) do
     1
  end

  defp fib(n) do
     fib(n-1) + fib(n-2)
  end

  # 普通にリストで取得
  def list(n) do
    Enum.map_join 1..n, fn x ->
      fib x
    end
  end

  # Streamで作った無限列から取得。遅延評価が効くのでtake出とる個数を指定すれば使える
  def stream(cnt) do
    Stream.unfold(1, fn n ->
      {fib(n), n + 1}
    end)
    |> Enum.take(cnt)
    |> Enum.map(fn n -> Integer.to_string(n) end)
  end

end

# 結果は同じ
IO.puts Fibonacci.list 10
IO.puts Fibonacci.stream 10
