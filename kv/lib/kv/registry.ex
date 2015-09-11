defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts \\ []) do
    # 3つの引数をpassingする新しいGenServerをスタートする
    # arg1 は server callbackが実装されているモジュールで `__MODULE__` は現在のモジュールを指す
    # arg2 は 初期設定でこの場合はatom
    # arg3 は オプションのリスト
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # call/2 は serverからresponseが返るrequest
    # serverに渡す命令は tupleにして先頭をserverへの命令を意味するatom をつけることが多い
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    # cast/2 はserverからresponseが帰らないrequest
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.call(server, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    # 単に新しいHashDictを返していたところをnamesとrefsのtupleを返すようにする
    names = HashDict.new
    refs  = HashDict.new
    {:ok,  {names, refs}}
  end

  # パターンマッチを使って対応するstateを取り出す
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, HashDict.fetch(names, name), state}
  end

  def handle_call(:stop, _from, state) do
   {:stop, :normal, :ok, state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if HashDict.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.Bucket.start_link()
      ref = Process.monitor(bucket)
      refs = HashDict.put(refs, ref, name)
      names = HashDict.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  # bucketのプロセスがダウンした時のコールバック
 def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
   # refsから対応するBucketの名前を取り出しつつ削除
   {name, refs} = HashDict.pop(refs, ref)
   # namesから削除
   names = HashDict.delete(names, name)
   {:noreply, {names, refs}}
 end

 # すべてのイベントをキャッチするコールバック
 def handle_info(_msg, state) do
   # 特に何もせず、stateだけを回す
   {:noreply, state}
 end

end
