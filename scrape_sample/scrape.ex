defmodule Commic do
  defstruct title: "",
    author: "",
    publisher: ""
end

defmodule ScrapeSample do

  # requireで指定するライブラリを指定
  require HTTPoison
  require Floki

  # コンテンツを取得
  def fetch_content(url) do
    HTTPoison.start
    URI.encode(url)         # Urlエンコード
    |> HTTPoison.get        # リクエスト
    |> proccess_response    # レスポンス処理
  end

  # 200を受け取った時の処理
  def proccess_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Floki.find(body, "ul")
    |> Enum.slice(1, 5)     # 必要な部分だけ切り出し。これ以外判定方法が思いつかなかった。。。
    |> Floki.find("li")     # 1タイトルずつ切り出し
    |> Enum.map(fn x ->     # タイトルと作者をバラして返す
        %Commic{
          title: (Floki.find(x, "a") |> Floki.FlatText.get),
          author: (Floki.FlatText.get(x) |> trim_space |> trim_braket)
        }
    end)

    |> Enum.map(fn x ->     # 作者を作者と出版社に分解
      %Commic{x | author: extract_author(x.author), publisher: extract_publisher(x.author)}
    end)

    # タイトルと作者が正しく取れている漫画だけ抜き出す
    |> Enum.filter(fn x ->
      0 < String.length(x.title) &&
      0 < String.length(x.author) &&
      0 < String.length(x.publisher)
    end)
  end

  # 作者名を取得
  def extract_author(authorAndPublisher) do
   case String.split(authorAndPublisher, "、") do
     list when 0 < length(list) ->
       String.replace(hd(list), ~r/^(原作：)/, "")
     _ ->
       ""
   end
  end

  # 出版社 または掲載雑誌を取得
  def extract_publisher(authorAndPublisher) do
   case String.split(authorAndPublisher, "、") do
     list when 1 < length(list) ->
       List.last list
     _ ->
       ""
   end
  end

  # 先頭と末尾からスペースを取り除く
  def trim_space(x) do
    cond do
      String.match?(x, ~r/^( |　).*( |　）)$/) ->
       String.slice(x, 1, String.length(x) - 2)
      String.match?(x, ~r/^( |　).*/) ->
       String.slice(x, 1, String.length(x))
      String.match?(x, ~r/.*( |　）)$/) ->
       String.slice(x, 0, String.length(x) - 1)
      true ->
      x
    end
  end

  # 先頭と末尾からブラケットを取り除く
  def trim_braket(x) do
    cond do
       String.match?(x, ~r/^(\(|（).*(\)|）)$/) ->
         String.slice(x, 1, String.length(x) - 2)
       String.match?(x, ~r/^(\(|（).*/) ->
         String.slice(x, 1, String.length(x))
       String.match?(x, ~r/.*(\)|）)$/) ->
         String.slice(x, 0, String.length(x) - 1)
      true ->
        x
    end
  end

  def proccess_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    "Not found :("
  end

  def proccess_response({:ok, %HTTPoison.Response{status_code: status_code}}) do
    "Error!! Status is " <> Integer.to_string(status_code)
  end

  def proccess_response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect reason
  end

end

ScrapeSample.fetch_content("https://ja.wikipedia.org/wiki/日本の漫画作品一覧_あ行")
|> Enum.map(fn x ->
  IO.puts x.title
  IO.puts x.author
  IO.puts x.publisher
  IO.puts ""
end)
