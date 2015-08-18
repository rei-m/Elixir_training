defmodule Shinchoku do

  @list ["進捗", "どう", "です", "か"]
  @len length(@list)
  @success Enum.join(@list)

  defp get_random do
     Enum.at(@list, :random.uniform(@len) - 1)
  end

  defp doudesuka(s) do
    case String.ends_with?(s, @success) do
      true -> "#{s}???\n#{String.length(s)}文字で煽られました。！！！！！"
      false -> doudesuka(s <> get_random)
    end
  end

  def doudesuka do
    :random.seed :os.timestamp
    doudesuka(get_random)
  end
end

IO.puts Shinchoku.doudesuka
