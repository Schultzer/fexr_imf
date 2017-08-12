defmodule FexrImf do
  require Logger

  defp query(date) do
    ConCache.get_or_store(:imf, "#{date}", fn ->
      date
      |> url
      |> fetch
      |> Floki.find("table.tighter")
      |> format_table
    end)
  end

  def symbols do
    ["AED", "AUD", "BHD", "BND", "BRL", "BWP", "CAD", "CHF", "CLP", "CNY", "COP",
     "CZK", "DKK", "DZD", "EUR", "GBP", "HUF", "IDR", "ILS", "INR", "IRR", "ISK",
     "JPY", "KRW", "KWD", "KZT", "LKR", "LYD", "MUR", "MXN", "MYR", "NOK", "NPR",
     "NZD", "OMR", "PEN", "PHP", "PKR", "PLN", "QAR", "RUB", "SAR", "SEK", "SGD",
     "THB", "TND", "TTD", "USD", "UYU", "VEF", "ZAR"]
  end

  defp currency_name_to_symbol do
    %{"Swedish Krona" => "SEK", "Saudi Arabian Riyal" => "SAR",
      "Chilean Peso" => "CLP", "Brazilian Real" => "BRL", "Botswana Pula" => "BWP",
      "Nuevo Sol" => "PEN", "New Zealand Dollar" => "NZD", "Euro" => "EUR",
      "Indonesian Rupiah" => "IDR", "Danish Krone" => "DKK",
      "Pakistani Rupee" => "PKR", "Mexican Peso" => "MXN",
      "Philippine Peso" => "PHP", "Japanese Yen" => "JPY", "U.S. Dollar" => "USD",
      "Bolivar Fuerte" => "VEF", "Czech Koruna" => "CZK", "Qatar Riyal" => "QAR",
      "U.K. Pound Sterling" => "GBP", "Kazakhstani Tenge" => "KZT",
      "Korean Won" => "KRW", "Icelandic Krona" => "ISK", "Iranian Rial" => "IRR",
      "South African Rand" => "ZAR", "Thai Baht" => "THB",
      "Singapore Dollar" => "SGD", "Indian Rupee" => "INR",
      "Trinidad And Tobago Dollar" => "TTD", "Kuwaiti Dinar" => "KWD",
      "Hungarian Forint" => "HUF", "Mauritian Rupee" => "MUR",
      "Colombian Peso" => "COP", "Swiss Franc" => "CHF", "U.A.E. Dirham" => "AED",
      "Bahrain Dinar" => "BHD", "Malaysian Ringgit" => "MYR",
      "Peso Uruguayo" => "UYU", "Polish Zloty" => "PLN", "Chinese Yuan" => "CNY",
      "Libyan Dinar" => "LYD", "Israeli New Sheqel" => "ILS",
      "Canadian Dollar" => "CAD", "Sri Lanka Rupee" => "LKR",
      "Norwegian Krone" => "NOK", "Brunei Dollar" => "BND",
      "Nepalese Rupee" => "NPR", "Algerian Dinar" => "DZD",
      "Tunisian Dinar" => "TND", "Australian Dollar" => "AUD",
      "Rial Omani" => "OMR", "Russian Ruble" => "RUB"}
  end

  defp url(date), do: "https://www.imf.org/external/np/fin/data/rms_mth.aspx?SelectDate=#{date}&reportType=SDRCV"

  defp fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info "Code: 200 URL: #{url}"
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info "Code: 404 URL: #{url}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error reason
    end
  end

  defp format_table([one, _, _]), do: format_table(one)
  defp format_table([one, two, _, _]), do: format_table(one, two)
  defp format_table(one, two), do: Map.merge(format_table(one), format_table(two), fn(_k, v1, v2) -> v1 ++ v2 end)
  defp format_table({tag, att, val}) do
    table = {tag, att, val} |> filter_table
    names = Enum.at(table, 0)
    dates = Enum.at(table, 1)

    Enum.reject(table, fn(x) -> x == names or x == dates end)
    |> serialize(format_dates(dates))
    |> map_merge
  end

  defp filter_table([]), do: []
  defp filter_table(string) when is_binary(string), do: string |> String.trim_leading |> String.trim_trailing
  defp filter_table([one, _two, _three, _four]), do: filter_table(one)
  defp filter_table({_tag, _value, list}), do: for n <- list, do: filter_table(n)

  defp serialize(rates, dates), do: for rate <- rates, do: serialize_rate(rate, dates)

  defp serialize_rate([name | rates], dates) do
    %{parse(name) => serialize_rates(rates, dates)}
  end

  defp serialize_rates([], []), do: []
  defp serialize_rates([[rate] | rates], [date | dates]), do: [{date, rate} | serialize_rates(rates, dates)]


  defp format_dates([]), do: []
  defp format_dates([[""] | tail]), do: format_dates(tail)
  defp format_dates([["Currency"] | tail]), do: format_dates(tail)
  defp format_dates([[month_date, [], year] | tail]) do
    [month_name, day] = month_date |> String.replace(",", "") |> String.split(" ")
    {:ok, date} = Date.new(convert(year), convert(month_name), convert(day))

    [date | format_dates(tail)]
  end


  defp convert(input) do
  input = String.downcase(input)
  months =  ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]

  case Enum.any?(months, fn(month) -> matches_month?(input, month) end) do
    true  -> month_number(input, months)
    false -> String.to_integer(input)
  end
  end

  defp matches_month?(name, month), do: String.starts_with?(name, month)

  defp month_number(name, months), do: Enum.find_index(months, fn (month) -> matches_month?(name, month) end) + 1

  defp month_number?("jan"), do: 1
  defp month_number?("feb"), do: 2
  defp month_number?("mar"), do: 3
  defp month_number?("apr"), do: 4
  defp month_number?("may"), do: 5
  defp month_number?("jun"), do: 6
  defp month_number?("jul"), do: 7
  defp month_number?("aug"), do: 8
  defp month_number?("sep"), do: 9
  defp month_number?("oct"), do: 10
  defp month_number?("nov"), do: 11
  defp month_number?("dec"), do: 12


  defp parse(name) when is_binary(name), do: currency_name_to_symbol[name]
  defp parse([name]), do: currency_name_to_symbol[name]

  defp map_merge(currencies, acc \\ %{})
  defp map_merge([], acc), do: acc
  defp map_merge([currency | currencies], acc), do: map_merge(currencies, Map.merge(currency, acc))

  defp filter(rates, []), do: rates
  defp filter(rates, nil), do: rates
  defp filter(rates, symbols), do: Map.take(rates, symbols)

  defp format_rates(rates, date, base) do
    base_rate = find_rate(date, rates[base])

    for c <- symbols do
      %{c => calc_exr(base_rate, find_rate(date, rates[c]))}
    end
    |> map_merge
    |> Map.delete(base)
  end

  defp find_rate(date, rates), do: Enum.find(rates, fn({d, r}) -> d == date end)

  defp calc_exr(nil, nil), do: "NA"
  defp calc_exr({ _date, _base}, {_date, "NA"}), do: "NA"
  defp calc_exr({ _date, base}, {_date, rate}) do
    exr = (String.to_float(base) / String.to_float(rate))
  end

  defp convert_symbols(symbols) do
    symbols
    |> Enum.reject(fn(l) -> not is_atom(l) and not is_binary(l) end)
    |> Enum.map(fn(l) -> if is_atom(l), do: Atom.to_string(l) |> String.upcase, else: String.upcase(l) end)
  end

  def rates({{year, month, day}, base, symbols}) do
    date = Date.from_erl!({year, month, day})

    date
    |> Date.to_string
    |> query
    |> format_rates(date, base)
    |> filter(symbols)
  end

  @moduledoc """
  Documentation for FexrImf.
  """

  @doc """
  returns a map with exchange rates,
  an options is provided to select symbols, default is set to all available symbols


  ## Examples

      iex> FexrImf.rates({2017, 8, 8}, :EUR, ["USD"])
      %{"USD" => 1.1814001721291816}

  """
  def rates(date, base \\ "USD", symbols \\ [])
  def rates(date, _base, _symbols) when not is_tuple(date), do: raise ArgumentError, "date has to be erl format {year, month, day}"
  def rates(_date, _base, symbols) when not is_list(symbols), do: raise ArgumentError, "symbols has to be in a list"
  def rates(date, base, symbols) when is_atom(base), do: rates(date, Atom.to_string(base) |> String.upcase, symbols)
  def rates(date, base, symbols) when is_list(symbols), do: rates({date, base, convert_symbols(symbols)})
end
