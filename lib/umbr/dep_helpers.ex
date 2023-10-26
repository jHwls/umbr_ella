defmodule Umbr.DepHelpers do
  @moduledoc false

  @doc false
  def normalize({_name, _vsn, _opts} = dep_tuple) do
    dep_tuple
  end

  def normalize({name, vsn}) when is_binary(vsn) do
    {name, vsn, []}
  end

  def normalize({name, opts}) when is_list(opts) do
    {name, ">= 0.0.0", opts}
  end

  @doc false
  def match?(dep, names_or_tags) do
    is_named?(dep, names_or_tags) || tags_intersect?(dep, names_or_tags)
  end

  defp is_named?({name, _vsn, _opts}, names), do: name in names

  defp tags_intersect?(dep, tags) do
    dep
    |> tag_set()
    |> MapSet.disjoint?(MapSet.new(tags))
    |> Kernel.!()
  end

  @doc false
  def tag_set({_name, _vsn, opts} = _dep) do
    opts
    |> Keyword.get(:tags, [])
    |> MapSet.new()
  end

  @doc false
  def excluded?({_name, _vsn, opts}) do
    case Keyword.get(opts, :only) do
      nil -> false
      [_ | _] = envs -> Mix.env() not in envs
      env -> Mix.env() !== env
    end
  end

  @doc false
  def force_compile({name, vsn, opts} = _dep) do
    {name, vsn, Keyword.delete(opts, :only)}
  end
end
