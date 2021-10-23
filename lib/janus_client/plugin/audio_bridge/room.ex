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
  Returns a map for the create_room request to Janus. Takes a keyword list of options, with the following optional keys 
  - room_id:          Integer, defaults to nil
  - admin_key:        String,  defaults to nil
  - permanent:        Boolean, defaults to false
  - description:      String,  defaults to nil
  - secret:           Integer, defaults to nil
  - pin:              Integer, defaults to nil
  - record:           Boolean, defaults to false
  - record_file:      String,  defaults to nil
  - record_dir:       String,  defaults to nil
  - audiolevel_event: Boolean, defaults to nil
  """
  @spec creation_request_body([]) :: map()
  def creation_request_body(opts \\ []) do
    request = %{
      request: "create",
      admin_key: opts[:admin_key],
      is_private: true,
      room: opts[:room_id],
      permanent: opts[:permanent],
      description: opts[:description],
      secret: opts[:secret],
      pin: opts[:pin],
      record: opts[:record],
      record_file: opts[:record_file],
      record_dir: opts[:record_dir],
      audiolevel_event: opts[:audiolevel_event]
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

