# Blankというプロトコルを定義
defprotocol Blank do
  @doc "Returns true if data is considered blank/empty"
  @fallback_to_any true
  def blank?(data)
end

# User Structを定義
defmodule User do
    defstruct name: "john", age: 27
end

# プロトコルを実装
# Integers are never blank
defimpl Blank, for: Integer do
  def blank?(_), do: false
end

# Just empty list is blank
defimpl Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

# Just empty map is blank
defimpl Blank, for: Map do
  # Keep in mind we could not pattern match on %{} because
  # it matches on all maps. We can however check if the size
  # is zero (and size is a fast operation).
  def blank?(map), do: map_size(map) == 0
end

# Just the atoms false and nil are blank
defimpl Blank, for: Atom do
  def blank?(false), do: true
  def blank?(nil),   do: true
  def blank?(_),     do: false
end

defimpl Blank, for: User do
  def blank?(%User{name: ""}), do: true
  def blank?(_), do: false
end

defimpl Blank, for: Any do
  def blank?(_), do: false
end
