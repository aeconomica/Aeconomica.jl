"""
    fetch_series_as_at(code::AbstractString, as_at_date::AbstractString)

Fetch series with series_id `code`, with whatever the latest vintage of
the series was as at the date specified by `as_at_date`.

as_at_date must be a date in YYYY-MM-DD form.

Returns a dataframe with four colums: `dates`, `as_at_date`, `series_id`, `values`.
"""
function fetch_series_as_at(code::AbstractString, as_at_date::AbstractString = "latest")
    fetch_series_as_at([code => as_at_date])
end

"""
    fetch_series_as_at(codes::AbstractArray{<:AbstractString, 1}, as_at_date::AbstractString)

Fetch a list of series with codes given by the array `codes`, with whatever the latest vintage of
the series was as at the date specified by `as_at_date`.

as_at_date must be a date in YYYY-MM-DD form.

Returns a dataframe with four colums: `dates`, `as_at_date`, `series_id`, `values`.
"""
function fetch_series_as_at(codes::AbstractArray{<:AbstractString, 1}, as_at_date::AbstractString)
    series = map(c -> c => as_at_date, codes)

    fetch_series_as_at(series)
end

"""
    fetch_series_as_at(series::AbstractArray{T, 1}) where T <: Pair{<:AbstractString, <:AbstractString}

Fetch a list of series with specified series codes, with whatever the latest vintage of
the series was as at the date specified by `as_at_date`.

Each element of the list is a pair `series_code` => `as_at_date`.

as_at_date must be a date in YYYY-MM-DD form.

Returns a dataframe with four colums: `dates`, `as_at_date`, `series_id`, `values`.

# Example
```
fetch_series_as_at(["CPI" => "2021-01-01", "CPI_SYD" => "2019-01-01"])
````
"""
function fetch_series_as_at(series::AbstractArray{T, 1}) where T <: Pair{<:AbstractString, <:AbstractString}
    map(p -> begin 
        check_valid_code(p[1])
        check_valid_as_at_date(p[2])
    end, series)

    series_req = join(
        map(p -> """{ "id" : "$(p[1])", "as_at_date" : "$(p[2])" }""", series),
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
        if error[1:21] == "500 Internal Error - "
            error = error[22:end]
            throw(ErrorException(error))
        else
            throw(ErrorException(error))
        end
    end
end