module Aeconomica

using HTTP: HTTP
using JSON3: JSON3
using DataFrames: DataFrames
using Dates: Dates

export fetch_series, set_apikey, fetch_series_as_at, fetch_dataset

const stored_apikey = Ref{String}("")

function __init__()
    if haskey(ENV, "AECONOMICA_APIKEY")
        stored_apikey[] = ENV["AECONOMICA_APIKEY"]
    end
end

function apikey()
    if stored_apikey[] == ""
        throw(
            ErrorException(
                "You have not set an `apikey`. Please run `set_apikey(\"YOURKEY\")` first."
            ),
        )
    else
        return stored_apikey[]
    end
end

"""
    set_apikey(key)

Set the API key to be used for requests. API keys are shown on the account page
(https://aeconomica.io/account).

Alternatively, you can set the environmental variable `AECONOMICA_APIKEY`, which will
be loaded at package load time.

You can overwrite this key at anytime by calling `set_apikey` again.
"""
function set_apikey(key)
    return stored_apikey[] = key
end

include("utils.jl")
include("series.jl")
include("series_as_at.jl")
include("dataset.jl")

end # module
