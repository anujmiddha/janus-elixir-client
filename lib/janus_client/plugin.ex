defprotocol JanusClient.Plugin do
  @doc """
  Plugin name to send to Janus for attaching. e.g. AudioBridge "janus.plugin.audiobridge"
  """
  @spec name(t) :: String.t()
  def name(plugin)

  @doc """
  Instantiate the plugin from the API response
  """
  @spec from_server_response(JanusClient.Plugin.t(), JanusClient.t(), %{optional(atom) => any}) :: t
  def from_server_response(plugin, client, response)
end

