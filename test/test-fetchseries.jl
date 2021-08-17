@testset "Fetchseries" begin

    res = fetch_series("CPI")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series("CPI", "latest")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series(["CPI", "CPI_SYD"], "latest")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series(["CPI" => "latest", "CPI_SYD" => "latest"])
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series("GDP_YE")
    @test all(.!isnothing.(res.values))

    @testset "Errors" begin
        @test_throws ErrorException("`*` is not a valid series code") fetch_series("*")
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series("valid_but_nonexistent")
        @test_throws ErrorException("Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`") fetch_series("CPI", "abc")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series(["CPI", "*"])
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series(["CPI", "valid_but_nonexistent"])
        @test_throws ErrorException("Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`") fetch_series(["CPI", "CPI_SYD"], "abc")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series(["CPI" => "latest", "*" => "latest"])
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series(["CPI" => "latest", "valid_but_nonexistent" => "latest"])
        @test_throws ErrorException("Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`") fetch_series(["CPI" => "latest", "CPI_SYD" => "abc"])
    end
end
