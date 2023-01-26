defmodule Deribit.Listener do
  require Logger

  def listen(websocket, data, f) do

    case Socket.Web.recv!(websocket) do
      {:text, text} ->
        parsed_text = M.dec!(text)
        case f do
          nil -> nil
          _ -> f.(parsed_text)
        end
        listen(websocket, Map.put(data, Time.utc_now(), parsed_text), f)
      {:ping, _} ->
        Socket.Web.send!(websocket, {:pong, ""})

      _msg ->
        Logger.debug("I received a msg.\n#{_msg}")
    end

    receive do
      {:data} -> IO.inspect data
      {:time} ->
        Time.utc_now()

      {:kill, reason} ->
        Logger.debug("received kill command.")
        Logger.debug("1) closing socket")
        Socket.Web.close(websocket)
        Logger.debug("2) killing receiver proc")
        Process.exit(self, reason)

      {:ping, _x} ->
        {:pong, Time.utc_now()}
    end
  end
end

# Deribit.API.WebSockets.start_link(); Deribit.API.WebSockets.authenticate(Deribit.client_id(), Deribit.client_secret())
# pid = Deribit.subscribe(%{"channels" => ["book.BTC-27DEC19-13000-C.raw"]})
