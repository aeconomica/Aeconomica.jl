@testset "Fetchseries" begin
    res = fetch_series("ABSCPIQTR")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test eltype(res.dates) <: Dates.Date
    @test eltype(res.vintage) <: Dates.Date
    @test eltype(res.series_id) <: String
    @test eltype(res.values) <: Union{Float64,Missing}

    res = fetch_series("ABSCPIQTR", "latest")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series(["ABSCPIQTR", "ABSCPIQTR_SYD_NSA"], "latest")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)

    res = fetch_series(["ABSCPIQTR" => "latest", "ABSCPIQTR_SYD_NSA" => "latest"])
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
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series(
            "valid_but_nonexistent"
        )
        @test_throws ErrorException(
            "Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`",
        ) fetch_series("ABSCPIQTR", "abc")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series([
            "ABSCPIQTR", "*"
        ])
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series([
            "ABSCPIQTR", "valid_but_nonexistent"
        ])
        @test_throws ErrorException(
            "Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`",
        ) fetch_series(["ABSCPIQTR", "ABSCPIQTR_SYD_NSA"], "abc")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series([
            "ABSCPIQTR" => "latest", "*" => "latest"
        ])
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series([
            "ABSCPIQTR" => "latest", "valid_but_nonexistent" => "latest"
        ])
        @test_throws ErrorException(
            "Invalid vintage `abc`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`",
        ) fetch_series(["ABSCPIQTR" => "latest", "ABSCPIQTR_SYD_NSA" => "abc"])
    end
end
