defmodule PlugSample do
  use Plug.Builder

  plug :set_header
  plug :send_ok

  def set_header(conn, _opts) do
    IO.puts "ここがはじめにうごく"
    put_resp_header(conn, "x-header", "set")
  end

  def send_ok(conn, _opts) do
    IO.puts "ここがつぎにうごく"
    send_resp(conn, 200, "ok")
  end
end

IO.puts "Running PlugSample with Cowboy on http://localhost:4000"
Plug.Adapters.Cowboy.http PlugSample, []
