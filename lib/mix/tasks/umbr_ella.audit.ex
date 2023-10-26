defmodule Mix.Tasks.Umbr.Audit do
  @shortdoc "Audit child app mix.exs files for usage of shared umbrella config"

  @moduledoc """
  # TODO
    
  """
  use Mix.Task
  alias Umbr.Helpers

  @impl Mix.Task
  def run(_args) do
    Helpers.umbrella_check!()
    apps_paths = Mix.Project.apps_paths()

    apps_paths
    |> Enum.map(fn {app, path} -> {app, Path.expand("mix.exs", path)} end)
    |> Enum.map(fn {app, path} -> {app, path, File.read!(path)} end)
    |> Enum.reject(fn {_app, _path, file} -> file =~ ~r/merge_umbrella_opts/ end)
    |> then(fn
      [] ->
        Mix.shell().info([:green, "No missing umbrella configs detected"])

      apps ->
        apps
        |> Stream.map(fn {app, _path, _file} -> app end)
        |> Enum.join(", ")
        |> then(&Mix.raise("There is no umbrella config detected in the following apps: #{&1}"))
    end)
  end
end
