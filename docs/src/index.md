# Aeconomica.jl

![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![CI](https://github.com/aeconomica/Aeconomica.jl/workflows/CI/badge.svg)
[![codecov.io](http://codecov.io/github/aeconomica/Aeconomica.jl/coverage.svg?branch=main)](http://codecov.io/github/aeconomica/Aeconomica.jl?branch=main)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://aeconomica.github.io/Aeconomica.jl/dev)

Aeconomica.jl provides quick and easy access to the [Aeconomica](https://aeconomica.io) data API.

To use this package, you will need to sign up for a free Aeconomica account to get an API key. You can find the API key in the [account page](https://aeconomica.io/account) of your
Aeconomica account.

## Installation

Aeconomica.jl is not registered in the Julia General registry. As such to install to the lastest release, run:
```
import Pkg
Pkg.add("https://github.com/aeconomica/Aeconomica.jl.git#release")
```

(Alternatively you can install the development version by removing the `#release`)

## Usage

To grab data for a series - e.g. the level of GDP - simply run (where "YOUR_API_KEY" is the API key from your Aeconomica account):

```
using Aeconomica
set_apikey("YOUR_API_KEY")
fetch_series("GDP")
```

To grab an entire dataset of series, and their dimensions - such as ABS weekly jobs by State - just run:

```
using Aeconomica
set_apikey("YOUR_API_KEY")
fetch_dataset("WJP_STATE")
```

In each case the series or dataset keys can be found by searching the Aeconomica website. When viewing a series or dataset, the key is shown in the top right.
You can also click on the "JULIA" button in the bottom left to get the code you need for the dataset you are viewing.
