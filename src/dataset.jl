"""
    fetch_dataset(dataset_id::AbstractString; restrictions::Dict{<:AbstractString, <:AbstractArray{<:AbstractString, 1}}, vintage::AbstractString = "latest", dimensions::Symbol = :code)

Fetch dataset with dataset_id `dataset_id`.

Restrictions is an (optional) dictionary with keys (corresponding to names of dimensions)
mapping to an Array of codes. Only series that have those codes for that dimension are
returned in the dataset.

Vintage can be any of `current` (alias `latest`, default), `previous` or a date in YYYY-MM-DD
form.

`dimensions` can be one of :code or :name. This dictates whether the values for each dimension
in the dataset are returned as the codes for each dimension (the default), or (for :name) the
long names that correspond to those codes.

Returns a dataframe, including columns: `values`, `vintage`. The dataframe will also have columns
for each of the dimensions of the dataset.
"""
function fetch_dataset(
    dataset_id::AbstractString;
    restrictions::Dict{<:AbstractString,<:AbstractArray{<:AbstractString,1}}=Dict{
        String,Array{String,1}
    }(),
    vintage::AbstractString="latest",
    dimensions::Symbol=:code,
)
    check_valid_vintage(vintage)
    check_valid_code(dataset_id)

    if dimensions != :code && dimensions != :name
        throw(ErrorException("`dimensions` can only be one of `:code` or `:name`"))
    end

    restrictions_string = if length(restrictions) > 0
        """"restrictions" : $(JSON3.write(restrictions)),"""
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
        "apikey" : "$(apikey())"}""";
        status_exception=false,
    )
    result = if res.status == 200
        response = JSON3.read(String(res.body))

        df = DataFrames.DataFrame(response)
        df.dates = Dates.Date.(df.dates)
        df.vintage = Dates.Date.(df.vintage)
        # replace nothing with missing - JSON3 treats null as nothing, but we want missing in this context
        df.values = map(x -> isnothing(x) ? missing : x, df.values)
        df.values = if any(ismissing.(df.values))
            Vector{Union{Float64,Missing}}(df.values)
        else
            Vector{Float64}(df.values)
        end

        df
    else
        error = JSON3.read(String(res.body))[:error]
        if res.status == 400
            throw(ErrorException(error[19:end]))
        elseif res.status == 401
            throw(
                ErrorException(
                    "Authorization required. Did you forget to provide an API key?"
                ),
            )
        elseif res.status == 403
            throw(
                ErrorException(
                    "Unauthorized. Check your API key and try again, or you may not have permissions for the requested resource.",
                ),
            )
        else
            if error isa Dict && haskey(error, :message)
                throw(ErrorException(error[:message]))
            else
                throw(ErrorException("Error accessing API; try again later"))
            end
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
            "apikey" : "$(apikey())"}""";
            status_exception=false,
        )
        structure = if res.status == 200
            JSON3.read(String(res.body))
        else
            error = JSON3.read(String(res.body))[:error]
            if res.status == 400
                throw(ErrorException(error[19:end]))
            elseif res.status == 401
                throw(
                    ErrorException(
                        "Authorization required. Did you forget to provide an API key?"
                    ),
                )
            elseif res.status == 403
                throw(
                    ErrorException(
                        "Unauthorized. Check your API key and try again, or you may not have permissions for the requested resource.",
                    ),
                )
            else
                if error isa Dict && haskey(error, :message)
                    throw(ErrorException(error[:message]))
                else
                    throw(ErrorException("Error accessing API; try again later"))
                end
            end
        end

        for dim in structure[:dimensions]
            #Iterate over each dimension, and replace the codes in the column of the df with their name
            result[!, dim[:dimname]] = map(
                code ->
                    dim[:options][findfirst(map(x -> code == x[:code], dim[:options]))][:name],
                result[:, dim[:dimname]],
            )
        end
    end

    return result
end
