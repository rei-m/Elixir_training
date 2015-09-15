defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  defmodule Forwarder do
     use GenEvent

     def handle_event(event, parent) do
       IO.inspect event
       send parent, event
       {:ok, parent}
     end
   end

  setup do
    # Bucketのsupervisorを開始
    {:ok, sup} = KV.Bucket.Supervisor.start_link
    # Event Managerを起動
    {:ok, manager} = GenEvent.start_link
    # EventManagerとBucketのsupervisorをレジストリに渡して起動
    {:ok, registry} = KV.Registry.start_link(manager, sup)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    # 未登録のBucketはエラーとなること
    assert KV.Registry.lookup(registry, "shopping") == :error

    # Bucketを新しく登録してBucketを取得できること
    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # 登録したBucketにKey-Valueを登録できること
    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1

    # レジストリが正しく止まること
    assert KV.Registry.stop(registry) == :ok
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "sends events on create and crash", %{registry: registry} do
    # bucketを作成した時にレジストリからイベントを受け取っていること
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    assert_receive {:create, "shopping", ^bucket}

    # bucketを破棄した時にレジストリからイベントを受け取っていること
    Agent.stop(bucket)
    assert_receive {:exit, "shopping", ^bucket}
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Kill the bucket and wait for the notification
    Process.exit(bucket, :shutdown)
    assert_receive {:exit, "shopping", ^bucket}
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
