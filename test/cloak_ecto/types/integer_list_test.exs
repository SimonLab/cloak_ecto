defmodule Cloak.Ecto.IntegerListTest do
  use ExUnit.Case

  defmodule Field do
    use Cloak.Ecto.IntegerList, vault: Cloak.Ecto.TestVault
  end

  defmodule ClosureField do
    use Cloak.Ecto.IntegerList, vault: Cloak.Ecto.TestVault, closure: true
  end

  @list [1, 2, 3, 4, 5]

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast rejects invalid types" do
    assert :error = Field.cast("binary")
    assert :error = Field.cast(123)
    assert :error = Field.cast(123.0)
    assert :error = Field.cast(hello: :world)
    assert :error = Field.cast(%{hello: :world})
    assert :error = Field.cast(["list", "of", "strings"])
  end

  test ".cast accepts lists" do
    assert {:ok, @list} = Field.cast(@list)
  end

  test ".cast unwraps closures" do
    assert {:ok, @list} = Field.cast(fn -> @list end)
  end

  test ".before_encrypt converts the list to a JSON string" do
    assert "[1,2,3,4,5]" = Field.before_encrypt(@list)
  end

  test ".dump encrypts the list" do
    {:ok, ciphertext} = Field.dump(@list)
    assert is_binary(ciphertext)
    assert ciphertext != @list
  end

  test ".load decrypts the list" do
    {:ok, ciphertext} = Field.dump(@list)
    assert {:ok, @list} = Field.load(ciphertext)
  end

  test ".load with closure option wraps decrypted value" do
    {:ok, ciphertext} = ClosureField.dump(@list)
    assert {:ok, closure} = ClosureField.load(ciphertext)
    assert is_function(closure, 0)
    assert @list = closure.()
  end
end
