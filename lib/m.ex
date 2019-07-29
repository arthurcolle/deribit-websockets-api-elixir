defmodule M do
  def enc!(map), do: Jason.encode!(map)
  def dec!(str), do: Jason.decode!(str)
end
