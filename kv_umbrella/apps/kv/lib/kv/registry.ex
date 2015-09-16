defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(ets, event_manager, buckets, opts \\ []) do
    # 3つの引数をpassingする新しいGenServerをスタートする
    # arg1 は server callbackが実装されているモジュールで `__MODULE__` は現在のモジュールを指す
    # arg2 は 初期設定でこの場合はatom
    # arg3 は オプションのリスト
    # GenServer.start_link(__MODULE__, event_manager, :ok)

    # start_linkでETSのプロセスとeventmanagerとbucketのsupervisorを受け取れるようにする
    GenServer.start_link(__MODULE__, {ets, event_manager, buckets}, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(table, name) do
    # call/2 は serverからresponseが返るrequest
    # serverに渡す命令は tupleにして先頭をserverへの命令を意味するatom をつけることが多い
    # GenServer.call(server, {:lookup, name})

    # 2. ETSを使わない場合はGenServer.callで:lookup イベントを送っていたが
    # 今のETSの場合はどのプロセスからでも参照できるので取り出したものをそのまま返せばよい
    case :ets.lookup(table, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    # cast/2 はserverからresponseが帰らないrequest
    GenServer.call(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.call(server, :stop)
  end

  ## Server Callbacks

  def init({ets, events, buckets}) do
    # 単に新しいHashDictを返していたところをnamesとrefsのtupleを返すようにする
    # names = HashDict.new
    # refs  = HashDict.new

    # ets  = :ets.new(table, [:named_table, read_concurrency: true])
    refs = :ets.foldl(fn {name, pid}, acc ->
      HashDict.put(acc, Process.monitor(pid), name)
    end, HashDict.new, ets)
    {:ok, %{names: ets, refs: refs, events: events, buckets: buckets}}
  end

  # パターンマッチを使って対応するstateを取り出す
  # def handle_call({:lookup, name}, _from, state) do
  #   {:reply, HashDict.fetch(state.names, name), state}
  # end

  # def handle_call(:stop, _from, state) do
  #  {:stop, :normal, :ok, state}
  # end

  def handle_call({:create, name}, _from, state) do
    # if HashDict.get(state.names, name) do
    #   {:noreply, state}
    # else
    #   # bucketのsupervisor経由でbucketのプロセスを作成する
    #   {:ok, pid} = KV.Bucket.Supervisor.start_bucket(state.buckets)
    #   ref = Process.monitor(pid)
    #   refs = HashDict.put(state.refs, ref, name)
    #   names = HashDict.put(state.names, name, pid)
    #
    #   # Event ManagerにPushイベントを送り、create を通知する
    #   GenEvent.sync_notify(state.events, {:create, name, pid})
    #   {:noreply, %{state | names: names, refs: refs}}
    # end
    # ETSから指定されたBucketのプロセスを探す
    case lookup(state.names, name) do
      {:ok, pid} ->
        {:reply, pid, state}
      :error ->
        # bucketのsupervisor経由でbucketのプロセスを作成する
        {:ok, pid} = KV.Bucket.Supervisor.start_bucket(state.buckets)
        # bucketの子プロセスを監視対象に入れる
        ref = Process.monitor(pid)
        # bucketの監視プロセスとbucket名をペアにして保存
        refs = HashDict.put(state.refs, ref, name)
        # ETSにbucketの名前とプロセスを保存
        :ets.insert(state.names, {name, pid})
        # Event Managerに create を通知。コールバックが実装されていればEventを受け取ることができる。
        GenEvent.sync_notify(state.events, {:create, name, pid})
        # bucketのpidと更新したstateを返す
        {:reply, pid, %{state | refs: refs}}
    end
  end

  # bucketのプロセスがダウンした時のコールバック
  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    # refsから対応するBucketの名前を取り出しつつ削除して監視を解除
    {name, refs} = HashDict.pop(state.refs, ref)
    # namesから削除して保存しているBucketの一覧から削除
    # names = HashDict.delete(state.names, name)
    :ets.delete(state.names, name)

    # Event ManagerにPushイベントを送り、exit を通知する
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    # {:noreply, %{state | names: names, refs: refs}}
    {:noreply, %{state | refs: refs}}
  end

 # すべてのイベントをキャッチするコールバック
 def handle_info(_msg, state) do
   # 特に何もせず、stateだけを回す
   {:noreply, state}
 end

end
