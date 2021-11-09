defmodule JanusClient.Plugin.AudioBridge do
  @moduledoc """
  Janus AudioBridge Plugin utilities
  """

  @type t :: %JanusClient.Plugin.AudioBridge{
    client: JanusClient.t() | nil,
    handle_id: integer() | nil
  }

  defstruct client: nil,
    handle_id: nil

  alias JanusClient.Plugin.AudioBridge.Room

  @doc """
  Create a new room for the given AudioBridge plugin
  """
  @spec create_room(JanusClient.Plugin.AudioBridge.t(), Room.create_properties) :: {:ok, Room.t()} | {:error, String.t()}
  def create_room(plugin, opts \\ []) do
    message_body = %{request: "create"}
                   |> Map.merge(Enum.into(opts, %{}))

    {:ok, response} = plugin.client.http_client
                      |> Tesla.post(plugin_url(plugin), plugin_message(message_body))

    case response.body do
      %{"janus" => "success", "plugindata" => plugindata} -> Room.on_create(plugindata)
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
    end
  end

  @doc """
  Edit an existing room for the given AudioBridge plugin
  """
  @spec edit_room(JanusClient.Plugin.AudioBridge.t(), JanusClient.Plugin.AudioBridge.Room.t(), Room.editable_properties) :: {:ok, Room.t()} | {:error, String.t()}
  def edit_room(plugin, room, opts) do
    message_body = %{request: "edit", room: room.room_id}
                   |> Map.merge(Enum.into(opts, %{}))
    {:ok, response} = plugin.client.http_client
                      |> Tesla.post(plugin_url(plugin), plugin_message(message_body))

    case response.body do
      %{"janus" => "success", "plugindata" => plugindata} -> Room.on_edit(room, plugindata, opts)
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
    end
  end

  @spec destroy_room(JanusClient.Plugin.AudioBridge.t(), JanusClient.Plugin.AudioBridge.Room.t(), boolean()) :: :ok, {:error, String.t()}
  def destroy_room(plugin, room, permanent) do
    message_body = %{request: "destroy", room: room.room_id, permanent: permanent}
    {:ok, response} = plugin.client.http_client
                      |> Tesla.post(plugin_url(plugin), plugin_message(message_body))

    case response.body do
      %{"janus" => "success", "plugindata" => %{"data" => %{"audiobridge" => "destroyed"}}} -> :ok
      %{"janus" => "success", "plugindata" => %{"data" => %{"error" => error}}} -> {:error, error}
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
    end
  end

  defp plugin_url(plugin) do
    "/janus/#{plugin.client.session.session_id}/#{plugin.handle_id}"
  end

  defp plugin_message(message_body) do
    %{
      janus: "message",
      transaction: JanusClient.new_transaction_id(),
      body: message_body
    }
  end

  defimpl JanusClient.Plugin, for: JanusClient.Plugin.AudioBridge do
    def name(_) do
      "janus.plugin.audiobridge"
    end

    def from_server_response(plugin, client, response) do
      {:ok, %{plugin | client: client, handle_id: response["id"]}}
    end
  end
end

