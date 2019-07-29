defmodule DeribitWs do
  @api_v2 "/ws/api/v2"

  def start_link do
    Agent.start_link(
      fn ->
        %{
          "websocket" =>
            Socket.Web.connect!(base_endpoint,
              path: @api_v2,
              secure: true
            )
        }
      end,
      name: __MODULE__
    )
  end

  def obtain_result(text) do
    # I'm looking for an access_token
    json = M.dec!(text)

    case Map.has_key?(json, "result") do
      true ->
        result = Map.get(json, "result")
        access = Map.has_key?(result, "access_token")
        refresh = Map.has_key?(result, "refresh_token")

        case access && refresh do
          true -> result
          _ -> raise "no results"
        end

      false ->
        raise "no results"
    end
  end

  ####### Authentication section

  ########## private
  defp params_for_auth(params \\ %{}) do
    %{}
    |> Map.put("grant_type", "client_credentials")
    |> Map.put("client_id", Map.get(params, "client_id"))
    |> Map.put("client_secret", Map.get(params, "client_secret"))
  end

  ########## private
  defp payload_for_auth(cid, csk) do
    %{}
    |> Map.put("method", "public/auth")
    |> Map.put("params", params_for_auth(%{"client_id" => cid, "client_secret" => csk}))
  end

  def authenticate(client_id, client_secret) do
    # The response contains 'result' if all is well, and you can use the
    # access_token and refresh_token to authenticate subsequent requests.
    # we store the entire deserialized 'result' in this module's Agent.
    #
    # So far, the Agent is keeping track of just 2 things:
    #     1) the underlying tcp socket used to maintain the websocket connection
    #
    #     2) the 'result' payload from the initial response from '/public/auth'
    #        this includes the following:
    #          access_token
    #          refresh_token
    #          token_type          "bearer"
    #          scope               account permissions
    #          expires_in          basically a TTL until access_token expires
    #
    # Now for every request until we need to re-authenticate (we know how long
    # we can use our access_token, from the expires_in TTL.

    new_m =
      Agent.get(__MODULE__, fn data ->
        ws = Map.get(data, "websocket")

        case Socket.Web.send!(ws, {:text, M.enc!(payload_for_auth(client_id, client_secret))}) do
          :ok ->
            case Socket.Web.recv!(ws) do
              {:text, text} ->
                IO.inspect(text)
                {:ok, Map.put(data, "result", obtain_result(text))}

              {:ping, _} ->
                {Socket.Web.send!({:pong, ""}), data}

              abc ->
                IO.inspect(abc)
            end

          :error ->
            raise "Error!"

          x ->
            IO.inspect(x)
        end
      end)

    {status, x} = new_m

    case status do
      :ok -> Agent.update(__MODULE__, fn m -> x end)
      _y -> raise "no new map: #{_y}"
    end
  end

  def base_method(mode, url, params \\ %{}) do
    case mode do
      :public ->
        pub = %{
          "method" => "public/" <> url,
          "params" => params
        }

        IO.inspect(pub)
        pub

      :private ->
        prv = %{
          "method" => "private/" <> url,
          "params" => params
        }

        IO.inspect(prv)
        prv
    end
  end

  # def ws, do: Agent.get(__MODULE__, fn data -> Map.get(data, "websocket") end)

  def get_public(url, params \\ %{}) do
    Agent.get(__MODULE__, fn data ->
      IO.inspect(data)
      ws = Map.get(data, "websocket")
      IO.inspect(params)

      # DeribitWs.start_link(); DeribitWs.authenticate(Deribit.client_id(), Deribit.client_secret())

      case Socket.Web.send!(
             ws,
             {:text, M.enc!(base_method(:public, url, params))}
           ) do
        :ok ->
          case Socket.Web.recv!(ws) do
            {:text, text} -> {:ok, M.dec!(text)}
            {:ping, _} -> Socket.Web.send!({:pong, ""})
          end
      end
    end)
  end

  def get_private(url, client_id, client_secret, params \\ %{}) do
    Agent.get(__MODULE__, fn data ->
      access_token =
        data
        |> Map.get("result")
        |> Map.get("access_token")

      ws = Map.get(data, "websocket")
      params = Map.put(params, "access_token", access_token)

      case Socket.Web.send!(
             ws,
             {:text, M.enc!(base_method(:private, url, params))}
           ) do
        :ok ->
          case Socket.Web.recv!(ws) do
            {:text, text} -> {:ok, M.dec!(text)}
            {:ping, _} -> Socket.Web.send!({:pong, ""})
          end
      end
    end)
  end

  defp get_timestamp do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> Kernel.*(1000)
  end

  def base_endpoint do
    case Application.get_env(:deribit, :test) do
      false -> Application.get_env(:deribit, :base_url)
      true -> Application.get_env(:deribit, :test_url)
    end
  end
end
