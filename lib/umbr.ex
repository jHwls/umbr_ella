defmodule Umbr do
  @moduledoc """
  Documentation for `Umbr`/`umbr_ella`.

  """
  alias Umbr.DepHelpers

  @doc "List common project opts for child apps"
  @callback umbrella_opts :: keyword()

  @doc "List common deps used by any/all umbrella apps. Child/sibling apps need not be listed."
  @callback umbrella_deps :: keyword()

  @doc "Override env specific exlcusions in the `only` dep opt"
  @callback force_compile?(dep :: term()) :: boolean()

  @optional_callbacks [force_compile?: 1]

  defmacro __using__(_opts) do
    quote do
      @behaviour Umbr
      import Umbr

      @doc """
      Merge a set of project opts from a child app with the common umbrella
      opts defined in `c:Umbr.umbrella_opts/0`.
        
      """
      def merge_umbrella_opts(opts) do
        Umbr.__merge_umbrella_opts__(__MODULE__, opts)
      end

      @doc """
      Get the deps specified common umbrella deps specified in 
      `c:Umbr.umbrella_deps/0`. Accepts a name or tag, or list of names,
      or tags.
        
      """
      def deps(names_or_tags) do
        Umbr.__deps__(__MODULE__, names_or_tags)
      end
    end
  end

  def __merge_umbrella_opts__(module, opts) when is_atom(module) do
    Keyword.merge(module.umbrella_opts(), opts)
  end

  def __deps__(module, deps) when is_atom(module) and is_list(deps) do
    {names_or_tags, deps} = Enum.split_with(deps, &is_atom/1)
    normalized_deps = Enum.map(deps, &DepHelpers.normalize/1)
    umbrella_and_sibling_deps = module.umbrella_deps() ++ __sibling_deps__()

    umbrella_and_sibling_deps
    |> Stream.map(&DepHelpers.normalize/1)
    |> Stream.filter(&DepHelpers.match?(&1, names_or_tags))
    |> Enum.concat(normalized_deps)
    |> Enum.map(&apply_overrides(module, &1))
  end

  def __deps__(module, name_or_tag) when is_atom(module) and is_atom(name_or_tag),
    do: __deps__(module, [name_or_tag])

  def __sibling_deps__ do
    apps =
      case Mix.Project.apps_paths() do
        %{} = apps_paths ->
          Map.keys(apps_paths)

        nil ->
          ".."
          |> File.ls!()
          |> Enum.map(&String.to_atom/1)
      end

    Enum.map(apps, &{&1, in_umbrella: true})
  end

  defp apply_overrides(module, {name, _, _} = dep) do
    if DepHelpers.excluded?(dep) and should_force_compile?(module, dep) do
      Mix.shell().info("Umbr: Forcing compilation of #{name}")
      DepHelpers.force_compile(dep)
    else
      dep
    end
  end

  defp should_force_compile?(module, dep) do
    function_exported?(module, :force_compile?, 1) and module.force_compile?(dep)
  end
end
