defmodule JanusClient.Plugin.AudioBridge.Room do
  @moduledoc """
  Represents a room from the AudioBridge plugin
  """

  alias JanusClient.Plugin.AudioBridge.Room

  @type t :: %Room{
    room_id: integer(),
    permanent: boolean(),
    secret: String.t() | nil,
    pin: String.t() | nil,
    record: boolean(),
    record_file: String.t() | nil,
    record_dir: String.t() | nil
  }

  @type create_properties :: [create_property]
  @type create_property :: {:room, integer()} |
    {:admin_key, String.t()} |
    {:permanent, boolean()} |
    {:description, String.t()} |
    {:secret, String.t()} |
    {:pin, String.t()} |
    {:is_private, boolean()} |
    {:allowed, [String.t()]} |
    {:sampling_rate, integer()} |
    {:spatial_audio, boolean()} |
    {:audiolevel_ext, boolean()} |
    {:audiolevel_event, boolean()} |
    {:audio_active_packets, integer()} |
    {:audio_level_average, integer()} |
    {:default_prebuffering, integer()} |
    {:record, boolean()} |
    {:record_file, String.t()} |
    {:record_dir, String.t()} |
    {:allow_rtp_participants, boolean()} |
    {:groups, [String.t()]}

  @type editable_properties :: [editable_property]
  @type editable_property :: {:new_description, String.t()} | {:new_secret, String.t()} | {:new_pin, String.t()} | {:new_is_private, boolean}

  defstruct [
    :room_id, permanent: false, secret: nil,
    pin: nil, record: false, record_file: nil, record_dir: nil
  ]

  @doc false
  @spec on_create(map()) :: {:ok, Room.t()} | {:error, String.t()}
  def on_create(%{"data" => %{"error" => error}}), do: {:error, error}
  def on_create(%{"data" => %{"room" => room_id, "permanent" => permanent}}) do
    {:ok,
      %Room{
        room_id: room_id,
        permanent: permanent
      }
    }
  end

  @spec on_edit(Room.t(), %{}, editable_properties) :: {:ok, Room.t()} | {:error, String.t()}
  def on_edit(_room, %{"data" => %{"error" => error}}, _opts), do: {:error, error}
  def on_edit(room, _plugindata, opts) do
    {:ok,
      Map.merge(room, replace_keys(Enum.into(opts, %{})))
    }
  end

  @spec replace_keys(map()) :: map()
  defp replace_keys(request_body) do
    mappings = %{new_description: :description, new_secret: :secret, new_pin: :pin, new_is_private: :is_private}
    
    request_body
    |> Enum.map(fn {key, value} -> {Map.get(mappings, key, key), value} end)
    |> Enum.into(%{})
  end
end

