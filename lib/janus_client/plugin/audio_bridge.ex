defmodule JanusClient.Plugin.AudioBridge do
  @moduledoc """
  Janus AudioBridge Plugin utilities
  """

  @type t :: %JanusClient.Plugin.AudioBridge{
    client: JanusClient.t(),
    handle_id: integer()
  }

  defstruct client: nil,
    handle_id: nil,
    transaction: nil

  alias JanusClient.Plugin.AudioBridge.Room

  @spec create_room(JanusClient.Plugin.AudioBridge.t()) :: {:ok, Room.t()}
  @spec create_room(JanusClient.Plugin.AudioBridge.t()) :: {:error, String.t()}
  def create_room(plugin, request_body \\ Room.creation_request_body()) do
    {:ok, response} = plugin.client.http_client
                      |> Tesla.post(plugin_url(plugin), room_creation_message(request_body))

    case response.body do
      %{"janus" => "success", "plugindata" => plugindata} -> Room.from_server_response(plugin, plugindata)
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
    end
  end

  defp plugin_url(plugin) do
    "/janus/#{plugin.client.session.session_id}/#{plugin.handle_id}"
  end

  defp room_creation_message(request_body) do
    %{
      janus: "message",
      transaction: JanusClient.new_transaction_id(),
      body: request_body
    }
  end

  defimpl JanusClient.Plugin, for: JanusClient.Plugin.AudioBridge do
    def name(_) do
      "janus.plugin.audiobridge"
    end

    def from_server_response(plugin, client, response) do
      %{plugin | client: client, handle_id: response["data"]["id"]}
    end
  end
end

