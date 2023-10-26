defmodule Umbr.DepHelpersTest do
  use ExUnit.Case, async: true
  alias Umbr.DepHelpers

  @valid_deps [
    {:ecto, "~> 3.9"},
    {:jason, "~> 1.3", tags: [:http]},
    {:myrmidex, github: "jHwls/myrmidex", only: [:dev, :test]},
    {:mint, "~> 1.4", tags: [:http]},
    {:sobelow, "~> 0.13.0", only: :prod, runtime: false, tags: [:web]}
  ]

  describe "&DepHelpers.normalize/1" do
    test "handles different dep types" do
      assert {:ecto, "~> 3.9", []} = DepHelpers.normalize(Enum.at(@valid_deps, 0))

      assert {:jason, "~> 1.3", [tags: [:http]]} = DepHelpers.normalize(Enum.at(@valid_deps, 1))

      assert {:myrmidex, ">= 0.0.0", [github: "jHwls/myrmidex", only: [:dev, :test]]} =
               DepHelpers.normalize(Enum.at(@valid_deps, 2))

      assert {:sobelow, "~> 0.13.0", [only: :prod, runtime: false, tags: [:web]]} =
               DepHelpers.normalize(Enum.at(@valid_deps, 4))
    end
  end

  describe "&DepHelpers.excluded?/1" do
    setup :normalize

    test "defaults to false", %{deps: deps} do
      refute DepHelpers.excluded?(Enum.at(deps, 0))
      refute DepHelpers.excluded?(Enum.at(deps, 1))
    end

    test "true with only opt and matching env", %{deps: deps} do
      refute DepHelpers.excluded?(Enum.at(deps, 2))
      assert DepHelpers.excluded?(Enum.at(deps, 4))
    end
  end

  defp normalize(_) do
    deps = Enum.map(@valid_deps, &DepHelpers.normalize/1)
    {:ok, deps: deps}
  end
end
