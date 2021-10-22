defmodule JanusClient.Plugin.AudioBridge.Room do
  @moduledoc """
  Represents a room from the AudioBridge plugin
  """

  alias JanusClient.Plugin.AudioBridge.Room

  @type t :: %Room{
    plugin: JanusClient.Plugin.AudioBridge.t(),
    room_id: integer(),
    permanent: boolean()
  }

  defstruct plugin: nil,
    room_id: nil,
    permanent: nil

  @doc """
  Returns a map for the create_room request to Janus
  """
  def creation_request_body(room_id \\ nil, permanent \\ false, description \\ nil, secret \\ nil, pin \\ nil,
    record \\ false, record_file \\ nil, record_dir \\ nil) do
    request = %{
      request: "create",
      is_private: true,
      room: room_id,
      permanent: permanent,
      description: description,
      secret: secret,
      pin: pin,
      record: record,
      record_file: record_file,
      record_dir: record_dir
    }

    request
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  @doc false
  @spec from_server_response(JanusClient.Plugin.AudioBridge.t(), %{}) :: {:ok, Room.t()} | {:error, String.t()}
  def from_server_response(_, %{"data" => %{"error" => error}}), do: {:error, error}
  def from_server_response(plugin, %{"data" => %{"room" => room_id, "permanent" => permanent}}) do
    {:ok,
      %Room{
        plugin: plugin,
        room_id: room_id,
        permanent: permanent
      }
    }
  end
end

