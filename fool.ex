defmodule Server do
  require Logger

  def accept(port) do
    # The options below mean:
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end


  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.debug("accept: " <> inspect(client))
    Task.start_link(fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(client) do
    case :gen_tcp.recv(client, 0) |> IO.inspect(limit: :infinity) do
      {:ok, "HELP\r\n"} -> :gen_tcp.send(client, "FLAG:{YouMuffinHead}+10points")
      _ -> nil
    end
  end
end

defmodule Server.Application do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
  @impl true
  def init([]) do
    port = String.to_integer(System.get_env("PORT") || "3306")
    children = [
      %{
        id: Server,
        start: {Server, :accept, [port]}
      }
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
#Server.accept(3306)
Server.Application.start_link()
:timer.sleep(:infinity)

