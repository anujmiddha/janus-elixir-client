# JanusClient

An Elixir library to interact with the Janus WebRTC Gateway server.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `janus_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:janus_client, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
admin_key = "admin_key"
client = JanusClient.initialize("https://janus-url")
         |> JanusClient.init_session()

{:ok, plugin} = JanusClient.attach_plugin(client, %JanusClient.Plugin.AudioBridge{})

# Create room
{:ok, room} = JanusClient.Plugin.AudioBridge.create_room(plugin, admin_key: admin_key, secret: "asd")

# Edit room
{:ok, room} = JanusClient.Plugin.AudioBridge.edit_room(plugin, room, new_secret: "qwe")

# Destroy room
:ok = JanusClient.Plugin.AudioBridge.destroy_room(plugin, room, false)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/janus_client](https://hexdocs.pm/janus_client).

