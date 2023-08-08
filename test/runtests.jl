using Aeconomica
using Test
using DataFrames
import Dates

using Aqua

Aqua.test_all(
    Aeconomica,
    ambiguities=false
)
Aqua.test_ambiguities(Aeconomica) # The default ambiguity test catches ambiguities in dependencies, which is not what we want to test

# Fetching without setting a key fails
set_apikey("")
@test_throws ErrorException("You have not set an `apikey`. Please run `set_apikey(\"YOURKEY\")` first.") fetch_series("CPI")

set_apikey(ENV["AECONOMICA_TEST_KEY"])

include("test-fetchseries.jl")
include("test-series_as_at.jl")
include("test-dataset.jl")
