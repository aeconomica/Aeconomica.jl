module Aeconomica

import HTTP, JSON, DataFrames, Dates

export fetch_series, set_apikey, fetch_series_as_at, fetch_dataset

mutable struct APIKey
    key::String
end

const stored_apikey = APIKey("")

function apikey()
    if stored_apikey.key == ""
        throw(ErrorException("You have not set an `apikey`. Please run `set_apikey(\"YOURKEY\")` first."))
    else
        stored_apikey.key
    end
end

function set_apikey(key)
    stored_apikey.key = key
end

include("utils.jl")
include("series.jl")
include("series_as_at.jl")
include("dataset.jl")

end # module
