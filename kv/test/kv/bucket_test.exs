defmodule KV.BucketTest do
  # asyncオプションは他のテストと並行で動くという指定。
  # ファイルへの書き込みやDBへの書き込みなど、競合する可能性がある場合は指定しない
  use ExUnit.Case, async: true

  # setup Macroは各テストの前に必ず実行される
  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    # 存在しないkeyを指定したらnilが返ること
    assert KV.Bucket.get(bucket, "milk") == nil

    # keyを指定してvalueを保存して値を取り出せること
    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "deletes values key", %{bucket: bucket} do

    # 存在しないキーを削除しようとしたらnilが返ること
    assert KV.Bucket.delete(bucket, "cheese") == nil

    # 値を保存
    KV.Bucket.put(bucket, "cheese", 1)

    # 指定したkeyで値を削除できること。削除の際、今持っている値が返ること
    assert KV.Bucket.delete(bucket, "cheese") == 1
    assert KV.Bucket.get(bucket, "cheese") == nil
  end

end
