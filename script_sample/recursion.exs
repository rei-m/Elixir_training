defmodule Recursion do

  # ガードによって n が 1 以下の場合のみ呼ばれる。再帰の終わり。
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  # 上の再帰の終了条件にかからない限りはnをでく裏面としながら自分を繰り返し呼ぶ
  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end

  # パターンマッチでList内の要素がある限りは再帰で繰り返す。
  # head = 先頭の要素 tail = それ以外の要素が束縛されていて、
  # 次回の呼び出し時のarg1にtailを指定することで呼び出すたびにListの要素が減っていく
  def sum_list([head|tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  # Listの要素が空の場合は再帰の終了
  def sum_list([], accumulator) do
    accumulator
  end

  # sum_listと似たような例。headは * 2しつつtailは再帰呼び出しの引数に渡す
  # 最終的にはリストの各要素がすべて * 2 される
  def double_each([head|tail]) do
    [head * 2|double_each(tail)]
  end

  # リストが空になったら再帰の終了
  def double_each([]) do
    []
  end

end

Recursion.print_multiple_times("Hello!", 3)
IO.puts Recursion.sum_list([1,2,3,4,5], 0)
IO.inspect Recursion.double_each([1,2,3,4,5])
