defmodule JanusClient do
  @moduledoc """
  Handle interaction with the Janus server.
  """

  @type t :: %__MODULE__{
    http_client: Tesla.Client.t(),
    session: JanusClient.Core.Session,
  }

  defstruct http_client: nil, session: nil

  alias JanusClient.Core.Session
  alias JanusClient.Plugin
  alias JanusClient.Plugin.AudioBridge
  
  def initialize(server_url) do
    %JanusClient{}
    |> init_http_client(server_url)
    |> init_session()
  end

  defp init_http_client(janus_client, server_url) do
    if janus_client.http_client == nil do
      middleware = [
        {Tesla.Middleware.BaseUrl, server_url},
        Tesla.Middleware.JSON
      ]
      http_client = Tesla.client(middleware)
      %{janus_client | http_client: http_client}
    else
      janus_client
    end
  end

  defp init_session(janus_client) do
    {:ok, response} = janus_client.http_client
                      |> Tesla.post("/janus", %{janus: "create", transaction: new_transaction_id()})
    case response.status do
      200 -> %{janus_client | session: session_from_response(response.body)}
      _-> janus_client
    end
  end

  def attach_plugin(janus_client, plugin \\ %AudioBridge{}) do
    {:ok, response} = janus_client.http_client
                      |> Tesla.post(session_url(janus_client),
                        %{janus: "attach", plugin: Plugin.name(plugin), transaction: new_transaction_id()})

    case response.body do
      %{"janus" => "success", "data" => data} -> Plugin.from_server_response(plugin, janus_client, data)
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
    end
  end

  def new_transaction_id do
    length = 10
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  defp session_url(janus_client) do
    "/janus/#{janus_client.session.session_id}"
  end

  defp session_from_response(response) do
    %Session{session_id: response["data"]["id"], transaction: response["transaction"]}
  end
end

