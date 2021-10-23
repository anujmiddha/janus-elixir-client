defmodule JanusClient do
  @moduledoc """
  Handle interaction with the Janus server.
  """

  @type t :: %__MODULE__{
    http_client: Tesla.Client.t(),
    session: JanusClient.Core.Session | nil,
  }

  defstruct http_client: nil, session: nil

  alias JanusClient.Core.Session
  alias JanusClient.Plugin
  alias JanusClient.Plugin.AudioBridge

  @doc """
  Initialize the client for Janus server with the given url
  """
  @spec initialize(String.t()) :: JanusClient.t()
  def initialize(server_url) do
    %JanusClient{http_client: init_http_client(server_url)}
  end
  
  #Initiate a Tesla HTTP Client with the given base url
  @spec init_http_client(String.t()) :: Tesla.Client.t()
  defp init_http_client(base_url) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON
    ]
    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}
    Tesla.client(middleware, adapter)
  end

  @doc """
  Instantiates a Janus session
  """
  # Initiate the Janus session
  @spec init_session(JanusClient.t()) :: JanusClient.t()
  def init_session(janus_client) do
    {:ok, response} = janus_client.http_client
                      |> Tesla.post("/janus", %{janus: "create", transaction: new_transaction_id()})
    case response.status do
      200 -> %{janus_client | session: session_from_response(response.body)}
      _-> janus_client
    end
  end

  @doc """
  Attach a plugin for the given JanusClient session
  """
  @spec attach_plugin(JanusClient.t(), plugin) :: {:ok, plugin} | {:error, String.t()} when plugin: JanusClient.Plugin
  def attach_plugin(janus_client, plugin) do
    {:ok, response} = janus_client.http_client
                      |> Tesla.post(session_url(janus_client),
                        %{janus: "attach", plugin: Plugin.name(plugin), transaction: new_transaction_id()})

    case response.body do
      %{"janus" => "success", "data" => data} -> Plugin.from_server_response(plugin, janus_client, data)
      %{"janus" => "error", "error" => %{"code" => code, "reason" => reason}} -> {:error, "[#{code}] #{reason}"}
      _ -> {:error, "Something went wrong"}
    end
  end

  @doc """
  Create a random 10 digit alphanumeric string to be used as the transaction id
  """
  @spec new_transaction_id() :: String.t()
  def new_transaction_id do
    length = 10
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  @spec session_url(JanusClient.t()) :: String.t()
  defp session_url(janus_client) do
    "/janus/#{janus_client.session.session_id}"
  end

  @spec session_from_response(map) :: JanusClient.Core.Session.t()
  defp session_from_response(response) do
    %Session{session_id: response["data"]["id"], transaction: response["transaction"]}
  end
end

