"""
    fetch_dataset(dataset_id::AbstractString; restrictions::Dict{<:AbstractString, <:AbstractArray{<:AbstractString, 1}}, vintage::AbstractString = "latest", dimensions::Symbol = :code)

Fetch dataset with dataset_id `dataset_id`.

Restrictions is an (optional) dictionary with keys (corresponding to names of dimensions)
mapping to an Array of codes. Only series that have those codes for that dimension are
returned in the dataset.

Vintage can be any of `current` (alias `latest`, default), `previous` or a date in YYYY-MM-DD
form.

`dimensions` can be one of :code or :name. This dictates whether the values for each dimension
of the dataset are returned as the codes for each dimension, or the long names that correspond
to those codes.

Returns a dataframe, including columns: `dates`, `vintage`, `series_id`, `values`. The dataframe
will also have columns for each of the dimensions of the dataset.
"""
function fetch_dataset(dataset_id::AbstractString; restrictions::Dict{<:AbstractString, <:AbstractArray{<:AbstractString, 1}} = Dict{String, Array{String, 1}}(), vintage::AbstractString = "latest", dimensions::Symbol = :code)
    check_valid_vintage(vintage)
    check_valid_code(dataset_id)

    if dimensions != :code && dimensions != :name
        throw(ErrorException("`dimensions` can only be one of `:code` or `:name`"))
    end

    restrictions_string = if length(restrictions) > 0
        """"restrictions" : $(JSON.json(restrictions)),"""
    else
        ""
    end

    # Get the data
    res = HTTP.request(
        "POST",
        "https://aeconomica.io/api/v1/dataset",
        [("Content-Type", "application/json")],
        """{
            "dataset" : "$dataset_id",
            $(restrictions_string)
            "vintage" : "$vintage",
        "apikey" : "$(apikey())"}""",
        status_exception = false)
    result = if res.status == 200
        response = JSON.parse(String(res.body), null = missing)
        df = reduce(vcat, map(x -> DataFrames.DataFrame(x), response))
        df.dates = Dates.Date.(df.dates)
        df.vintage = Dates.Date.(df.vintage)
        df.values = if any(ismissing.(df.values))
            Vector{Union{Float64, Missing}}(df.values)
        else
            Vector{Float64}(df.values)
        end

        df
    else
        error = JSON.parse(String(res.body))["error"]
        if error[1:21] == "500 Internal Error - "
            error = error[22:end]
            throw(ErrorException(error))
        else
            throw(ErrorException(error))
        end
    end

    # Convert to names if desired
    if dimensions == :name
        # Get the dataset structure
        res = HTTP.request(
            "POST",
            "https://aeconomica.io/api/v1/dataset_structure",
            [("Content-Type", "application/json")],
            """{
                "dataset" : "$dataset_id",
            "apikey" : "$(apikey())"}""",
            status_exception = false)
        structure = if res.status == 200
            JSON.parse(String(res.body), null = missing)
        else
            error = JSON.parse(String(res.body))["error"]
            if error[1:21] == "500 Internal Error - "
                error = error[22:end]
                throw(ErrorException(error))
            else
                throw(ErrorException(error))
            end
        end

        for dim in structure["dimensions"]
            #Iterate over each dimension, and replace the codes in the column of the df with their name
            result[!, dim["dimname"]] = map(code -> dim["options"][findfirst(map(x -> code == x["code"], dim["options"]))]["name"], result[:, dim["dimname"]])
        end
    end

    result
end