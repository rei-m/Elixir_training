defmodule Math do

  def sum(a, b) do
    do_sum(a, b)
  end

  defp do_sum(a, b) do
    a + b
  end

  def is_zero(x) when is_number(x) do
    false
  end

  def is_zero(0) do
    true
  end

  def sum_(a, b \\ 1) do
      a + b
  end

end
