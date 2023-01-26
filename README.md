# Deribit

Client for the [Deribit API v2](https://docs.deribit.com/v2/) over a secure WebSocket connection.

Adaptation and expansion of earlier work done by @gabrielpra1.
## Installation

The package can be installed by adding `deribit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deribit, "~> 0.2.0"}
  ]
end
```

Optionally, configure the client with default credentials to be used in private methods.
Set `test: true` to use the API's test endpoint

```elixir
config :deribit,
  client_id: "",
  client_secret: "",
  test: true # Defaults to false
```

## Usage

### Public

For endpoints with public scope, simply call a function with the name of the endpoint, optionally passing the parameters as a map:

```elixir
iex(1)> Deribit.test
{:ok,
 %{
   "jsonrpc" => "2.0",
   "result" => %{"version" => "1.2.26"},
   "testnet" => true,
   "usDiff" => 1,
   "usIn" => 1556750102206871,
   "usOut" => 1556750102206872
 }}
 
iex(2)> Deribit.test %{expected_result: "exception"}
{:error,
 {500,
  %{
    "error" => %{"code" => 11094, "message" => "internal_server_error"},
    "jsonrpc" => "2.0",
    "testnet" => true,
    "usDiff" => 101,
    "usIn" => 1556925879289043,
    "usOut" => 1556925879289144
  }}}
```

Errors have the format `{:error, {status, body}}` or `{:error, reason}`.

### Private

For endpoints with private scope, you can provide the user credentials or use the ones defined via configuration.

```elixir
iex(1)> Deribit.get_subaccounts
{:error,
 {400,
  %{
    "error" => %{"code" => 13004, "message" => "invalid_credentials"},
    "jsonrpc" => "2.0",
    "testnet" => true,
    "usDiff" => 19,
    "usIn" => 1556925904685704,
    "usOut" => 1556925904685723
  }}}
iex(2)> Deribit.get_account_summary("client_id", "client_secret", %{currency: "btc"})
{:error,
 {400,
  %{
    "error" => %{"code" => 13004, "message" => "invalid_credentials"},
    "jsonrpc" => "2.0",
    "testnet" => true,
    "usDiff" => 24,
    "usIn" => 1556925927518909,
    "usOut" => 1556925927518933
  }}}
```

## Setting up in an `iex` session
```
Deribit.API.WebSockets.start_link(); 
Deribit.API.WebSockets.authenticate(Deribit.client_id(), Deribit.client_secret())
```

## Just display bids  
```
{:ok, pid} = Deribit.subscribe(%{"channels" => ["book.BTC-PERPETUAL.raw"]}, fn(x) -> IO.inspect(x["params"]["data"]) end)
```

### Output:
```
%{      
  "asks" => [],
  "bids" => [["change", 22855.0, 248270.0]],
  "change_id" => 52728517366,
  "instrument_name" => "BTC-PERPETUAL",
  "prev_change_id" => 52728517364,
  "timestamp" => 1674506228989,
  "type" => "change"
}
%{      
  "asks" => [["change", 22861.5, 18010.0]],
  "bids" => [],
  "change_id" => 52728517368,
  "instrument_name" => "BTC-PERPETUAL",
  "prev_change_id" => 52728517366,
  "timestamp" => 1674506229003,
  "type" => "change"
}
%{      
  "asks" => [],
  "bids" => [["delete", 22849.5, 0.0], ["new", 22847.0, 260.0]],
  "change_id" => 52728517369,
  "instrument_name" => "BTC-PERPETUAL",
  "prev_change_id" => 52728517368,
  "timestamp" => 1674506229007,
  "type" => "change"
}
```

## Just display bids
```
{:ok, pid} = Deribit.subscribe(%{"channels" => ["book.ETH-PERPETUAL.raw"]}, fn(x) -> IO.inspect(x["params"]["data"]["bids"]) end)
```

### Output:
```
[["change", 1625.3, 27269.0]]
[["change", 1625.3, 25479.0]]
[["change", 1625.05, 68539.0], ["change", 1624.9, 22249.0]]
[["change", 1625.3, 27359.0]]
[["change", 1625.3, 25479.0]]
[["change", 1625.05, 28539.0], ["change", 1624.9, 62249.0]]
[]      
[]      
[["change", 1625.7, 97467.0]]
[]      
[]      
[]      
[["change", 1625.3, 27364.0]]
[["change", 1624.9, 46000.0]]
...
```

## Just display offers

```
{:ok, pid} = Deribit.subscribe(%{"channels" => ["book.ETH-PERPETUAL.raw"]}, fn(x) -> IO.inspect(x["params"]["data"]["asks"]) end)
```

### Output: 
```
[["new", 2438.55, 1.0]]
[]      
[]      
[]      
[["delete", 1625.8, 0.0]]
[["change", 1626.4, 42000.0], ["change", 1626.55, 77680.0]]
[]      
[["change", 1626.55, 82680.0], ["change", 1626.6, 137057.0]]
[]      
[["change", 1627.0, 3443.0]]
[["change", 1626.05, 14990.0]]
[] 
```

As you can see, the architecture enables you to just define a simple function to handle the data you are receiving in the subscription updates, in any way you want. You could use a database adapter in order to store data, you could just print out the data (as I am doing above to show you how it can work). You could also use a Agent to handle the data, or some kind of Task that handles each new message that comes through the WebSocket connection. The possibilities are endless and the only limit is your imagination. 😁 Happy trading!