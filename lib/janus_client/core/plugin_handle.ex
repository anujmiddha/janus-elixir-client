defmodule JanusClient.Core.PluginHandle do
  @moduledoc """
  Janus Plugin Handle

  Used to interact with Janus Plugins.
  """

  @type t :: %__MODULE__{
    handle_id: integer,
    session_id: integer,
    transaction: String.t()
  }

  defstruct handle_id: nil,
    session_id: nil,
    transaction: nil
end
