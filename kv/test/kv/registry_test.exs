defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    # レジストリを起動
    {:ok, registry} = KV.Registry.start_link
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
end
