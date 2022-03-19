@testset "Dataset" begin
    res = fetch_dataset("WJP_STATE", vintage = "latest")
    @test res isa DataFrames.DataFrame
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test "State" in DataFrames.names(res)
    @test eltype(res.dates) <: Dates.Date
    @test eltype(res.vintage) <: Dates.Date
    @test eltype(res.values) <: Union{Float64, Missing}

    res = fetch_dataset("WJP_STATE", restrictions = Dict("State" => ["TAS"]))
    @test res isa DataFrames.DataFrame
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test "State" in DataFrames.names(res)
    @test unique(res.State) == ["TAS"]

    res = fetch_dataset("WJP_STATE", restrictions = Dict("State" => ["TAS"]), dimensions = :name)
    @test res isa DataFrames.DataFrame
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test "State" in DataFrames.names(res)
    @test unique(res.State) == ["Tasmania"]

    @testset "Errors" begin
        @test_throws ErrorException("`*` is not a valid series code") fetch_dataset("*")
        @test_throws ErrorException("DataSet `valid_but_nonexistent` does not exist") fetch_dataset("valid_but_nonexistent")
        @test_throws ErrorException("Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`") fetch_dataset("WJP_STATE", vintage = "abc")
        @test_throws ErrorException("`dimensions` can only be one of `:code` or `:name`") fetch_dataset("WJP_STATE", dimensions = :fizz)
    end
end