defmodule JanusClient.Core.Session do

  @type t :: %__MODULE__{
    session_id: integer,
    transaction: String.t()
  }

  defstruct session_id: nil, transaction: nil
end

