defmodule Umbr.Helpers do
  @moduledoc false

  def umbrella_check! do
    Mix.Project.umbrella?() ||
      raise "Umbr: This command must be run from the root of an umbrella project."
  end
end
