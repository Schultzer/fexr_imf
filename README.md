# FexrImf

FexrImf serve you historical exchange rates from [https://www.imf.org](IMF) in a simple developer friendly map.

[![Build Status](https://travis-ci.org/Schultzer/fexr_imf.svg?branch=master)](https://travis-ci.org/Schultzer/fexr_imf)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fexr_imf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fexr_imf, "~> 0.1.0"}
  ]
end
```

## Methods

### `rates/3`
returns a map with exchange rates,
an options is provided to select symbols, default is set to all available symbols

```elixir
FexrImf.rates({2017, 8, 8}, :USD) => %{"EUR" => 0.8464532370921763 ...}
FexrImf.rates({2017, 8, 8}, "EUR", [:USD]) => %{"USD" => 1.1814001721291816}
```

## Documentation
[https://hexdocs.pm/fexr_imf](https://hexdocs.pm/fexr_imf)

## LICENSE

(The MIT License)

Copyright (c) 2017 Benjamin Schultzer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
