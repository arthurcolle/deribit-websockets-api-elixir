defmodule Deribit do
  @moduledoc """
   Deribit API client
  """

  @public [
    "auth",
    "get_time",
    "test",
    "get_announcements",
    "get_book_summary_by_currency",
    "get_book_summary_by_instrument",
    "get_contract_size",
    "get_currencies",
    "get_funding_chart_data",
    "get_historical_volatility",
    "get_index",
    "get_instruments",
    "get_last_settlement_by_currency",
    "get_last_settlement_by_instrument",
    "get_last_trades_by_currency",
    "get_last_trades_by_currency_and_time",
    "get_last_trades_by_instrument",
    "get_last_trades_by_instrument_and_time",
    "get_order_book",
    "get_trade_volumes",
    "ticker",
    "subscribe",
    "unsubscribe"
  ]

  @private [
    "get_subaccounts",
    "get_account_summary",
    "get_email_language",
    "get_new_announcements",
    "get_position",
    "get_positions",
    "get_current_deposit_address",
    "get_deposits",
    "get_transfers",
    "get_withdrawals",
    "buy",
    "sell",
    "edit",
    "cancel",
    "cancel_all",
    "cancel_all_by_currency",
    "cancel_all_by_instrument",
    "close_positions",
    "get_margins",
    "get_open_orders_by_currency",
    "get_open_orders_by_instrument",
    "get_order_history_by_currency"
  ]

  for endpoint <- @public do
    def unquote(String.to_atom(endpoint))(params \\ %{}),
      do: Deribit.API.WebSockets.get_public(unquote(endpoint), params)
  end

  for endpoint <- @private do
    def unquote(String.to_atom(endpoint))(params \\ %{}),
      do:
        Deribit.API.WebSockets.get_private(
          unquote(endpoint),
          client_id(),
          client_secret(),
          params
        )
  end

  def client_id(), do: Application.get_env(:deribit, :client_id)
  def client_secret(), do: Application.get_env(:deribit, :client_secret)
end
