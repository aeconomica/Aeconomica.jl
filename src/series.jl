"""
    fetch_series(code::AbstractString, vintage::AbstractString)

Fetch series with series_id `code`.

Vintage can be any of `current` (alias `latest`, default), `previous` or a date in YYYY-MM-DD
form.

Returns a dataframe with four colums: `dates`,  `series_id`, `values`, `vintage`.
"""
function fetch_series(code::AbstractString, vintage::AbstractString = "latest")
    fetch_series([code => vintage])
end

"""
    fetch_series(codes::AbstractArray{<:AbstractString, 1}, vintage::AbstractString)

Fetch a list of series with codes given by the array `codes`. For all series, fetch the
vintage given by `vintage`. 

Vintage can be any of `current` (alias `latest`, default), `previous` or a date in YYYY-MM-DD
form.

Returns a dataframe with four colums: `dates`,  `series_id`, `values`, `vintage`.
"""
function fetch_series(codes::AbstractArray{<:AbstractString, 1}, vintage::AbstractString = "latest")
    series = map(c -> c => vintage, codes)

    fetch_series(series)
end

"""
    fetch_series(series::AbstractArray{T, 1}) where T <: Pair{<:AbstractString, <:AbstractString}

Fetch a list of series with specified series codes and vintages.

Each element of the list is a pair `series_code` => `vintage`. Vintage must be explicitly specified.

Vintage can be any of `current` (alias `latest`), `previous` or a date in YYYY-MM-DD
form.

Returns a dataframe with four colums: `dates`,  `series_id`, `values`, `vintage`.

# Example
```
fetch_series(["CPI" => "latest", "CPI_SYD" => "previous"])
````
"""
function fetch_series(series::AbstractArray{T, 1}) where T <: Pair{<:AbstractString, <:AbstractString}
    map(p -> begin 
        check_valid_code(p[1])
        check_valid_vintage(p[2])
    end, series)

    series_req = join(
        map(p -> """{ "id" : "$(p[1])", "vintage" : "$(p[2])" }""", series),
        ", "
    )

    res = HTTP.request(
        "POST",
        "https://aeconomica.io/api/v1/fetchseries",
        [("Content-Type", "application/json")],
        """{
        "series": [
            $series_req
        ],
        "apikey" : "$(apikey())"}""",
        status_exception = false)
    if res.status == 200
        response = JSON.parse(String(res.body), null = missing)
        df = reduce(vcat, map(x -> DataFrames.DataFrame(x), response))
        df.dates = Dates.Date.(df.dates)
        df.vintage = Dates.Date.(df.vintage)
        df.values = if any(ismissing.(df.values))
            Vector{Union{Float64, Missing}}(df.values)
        else
            Vector{Float64}(df.values)
        end

        return df
    else
        error = JSON.parse(String(res.body))["error"]
        if error isa AbstractString && length(error) > 21 && error[1:21] == "500 Internal Error - "
            error = error[22:end]
            throw(ErrorException(error))
        else
            if error isa Dict && haskey(error, "message")
                throw(ErrorException(error["message"]))
            else
                throw(ErrorException("Error accessing API; try again later"))
            end
        end
    end
end
