defmodule Deribit.Listener do
  require Logger

  def listen(websocket, f) do
    case Socket.Web.recv!(websocket) do
      {:text, text} ->
        parsed_text = M.dec!(text)
        f.(parsed_text)
        listen(websocket, f)
      {:ping, _} ->
        Socket.Web.send!(websocket, {:pong, ""})

      msg ->
        Logger.debug("I received a msg...\n`#{msg}`")
    end

    receive do
      {:time} ->
        Time.utc_now()

      {:kill, reason} ->
        Logger.debug("received kill command.")
        Logger.debug("1) closing socket")
        Socket.Web.close(websocket)
        Logger.debug("2) killing receiver proc")
        Process.exit(self(), reason)

      {:ping, _x} ->
        {:pong, Time.utc_now()}
    end
  end
end
