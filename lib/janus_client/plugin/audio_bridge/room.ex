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

  @type request_create :: %{
    optional(:room_id) => integer(),
    optional(:admin_key) => String.t(),
    optional(:permanent) => boolean(),
    optional(:description) => String.t(),
    optional(:secret) => integer(),
    optional(:pin) => integer(),
    optional(:is_private) => boolean(),
    optional(:allowed) => [String.t()],
    optional(:sampling_rate) => integer(),
    optional(:spatial_audio) => boolean(),
    optional(:audiolevel_ext) => boolean(),
    optional(:audiolevel_event) => boolean(),
    optional(:audio_active_packets) => integer(),
    optional(:audio_level_average) => integer(),
    optional(:default_prebuffering) => integer(),
    optional(:record) => boolean(),
    optional(:record_file) => String.t(),
    optional(:record_dir) => String.t(),
    optional(:allow_rtp_participants) => boolean(),
    optional(:groups) => [String.t()] 
  }

  defstruct plugin: nil,
    room_id: nil,
    permanent: nil

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

