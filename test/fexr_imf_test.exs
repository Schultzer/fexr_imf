defmodule FexrImfTest do
  use ExUnit.Case
  doctest FexrImf

  test "rates/2" do
    rates = FexrImf.rates({2017, 8, 8}, "USD", [:EUR])
    assert Map.keys(rates) == ["EUR"]

    rates = FexrImf.rates({2017, 8, 8}, :EUR, ["usd", "PEN"])
    assert Map.keys(rates) == ["PEN", "USD"]
  end


end
