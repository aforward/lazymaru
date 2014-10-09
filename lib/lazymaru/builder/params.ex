defmodule Lazymaru.Builder.Params do
  alias Lazymaru.Router.Param

  defmacro requires(attr_name) do
    param(attr_name, [], true)
  end

  defmacro requires(attr_name, options, [do: block]) do
    [ param(attr_name, Dict.merge([type: :list], options), [required: true, nested: false]),
      quote do
        group = @group
        @group group ++ [unquote(attr_name)]
        unquote(block)
        @group group
      end
    ]
  end

  defmacro requires(attr_name, [do: block]) do
    [ param(attr_name, [type: :list], [required: true, nested: true]),
      quote do
        group = @group
        @group group ++ [unquote(attr_name)]
        unquote(block)
        @group group
      end
    ]
  end

  defmacro requires(attr_name, options) do
    param(attr_name, options, [required: true, nested: false])
  end


  defmacro group(group_name, options \\ [], [do: block]) do
    [ param(group_name, Dict.merge([type: :list], options), [required: true, nested: true]),
      quote do
        group = @group
        @group group ++ [unquote group_name]
        unquote(block)
        @group group
      end
    ]
  end

  defmacro optional(attr_name) do
    param(attr_name, [], [required: false, nested: false])
  end

  defmacro optional(attr_name, options, [do: block]) do
    [ param(attr_name, Dict.merge([type: :list], options), [required: false, nested: true]),
      quote do
        group = @group
        @group group ++ [unquote(attr_name)]
        unquote(block)
        @group group
      end
    ]
  end

  defmacro optional(attr_name, [do: block]) do
    [ param(attr_name, [type: :list], [required: false, nested: true]),
      quote do
        group = @group
        @group group ++ [unquote(attr_name)]
        unquote(block)
        @group group
      end
    ]
  end

  defmacro optional(attr_name, options) do
    param(attr_name, options, [required: false, nested: false])
  end


  defp param(attr_name, options, [required: required, nested: nested]) do
    parser = case options[:type] do
       nil -> nil
       {:__aliases__, _, [t]} -> [Lazymaru.ParamType, t] |> Module.concat
       t when is_atom(t) ->
         [ Lazymaru.ParamType, t |> Atom.to_string |> Lazymaru.Utils.upper_camel_case |> String.to_atom
         ] |> Module.safe_concat
    end
    quote do
      @param_context @param_context ++ [%Param{
        attr_name: unquote(attr_name), default: unquote(options[:default]), group: @group,
        required: unquote(required), nested: unquote(nested), parser: unquote(parser),
        validators: unquote(options) |> Dict.drop [:type, :default] |> Macro.escape
      }]
    end
  end
end
