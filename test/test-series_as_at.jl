@testset "Fetchseries" begin
    res = fetch_series_as_at("ABSCPIQTR", "2021-02-01")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test res.vintage[1] <= Dates.Date("2021-02-01")
    @test eltype(res.dates) <: Dates.Date
    @test eltype(res.vintage) <: Dates.Date
    @test eltype(res.series_id) <: String
    @test eltype(res.values) <: Union{Float64,Missing}

    res = fetch_series_as_at(["ABSCPIQTR", "ABSCPIQTR_SYD_NSA"], "2021-02-01")
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test res.vintage[1] <= Dates.Date("2021-02-01")

    res = fetch_series_as_at([
        "ABSCPIQTR" => "2021-02-01", "ABSCPIQTR_SYD_NSA" => "2021-02-01"
    ])
    @test res isa DataFrames.DataFrame
    @test DataFrames.ncol(res) == 4
    @test "dates" in DataFrames.names(res)
    @test "vintage" in DataFrames.names(res)
    @test "series_id" in DataFrames.names(res)
    @test "values" in DataFrames.names(res)
    @test res.vintage[1] <= Dates.Date("2021-02-01")

    @testset "Errors" begin
        @test_throws ErrorException("`*` is not a valid series code") fetch_series_as_at(
            "*", "2021-02-01"
        )
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series_as_at(
            "valid_but_nonexistent", "2021-02-01"
        )
        @test_throws ErrorException(
            "Invalid as_at_date `xxxx-yy-mm`. Date must be in form YYYY-MM-DD."
        ) fetch_series_as_at("ABSCPIQTR", "xxxx-yy-mm")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series_as_at(
            ["ABSCPIQTR", "*"], "2021-02-01"
        )
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series_as_at(
            ["ABSCPIQTR", "valid_but_nonexistent"], "2021-02-01"
        )
        @test_throws ErrorException(
            "Invalid as_at_date `xxxx-yy-mm`. Date must be in form YYYY-MM-DD."
        ) fetch_series_as_at(["ABSCPIQTR", "ABSCPIQTR_SYD_NSA"], "xxxx-yy-mm")

        @test_throws ErrorException("`*` is not a valid series code") fetch_series_as_at([
            "ABSCPIQTR" => "2021-02-01", "*" => "2021-02-01"
        ])
        @test_throws ErrorException("No series `valid_but_nonexistent` exists") fetch_series_as_at([
            "ABSCPIQTR" => "2021-02-01", "valid_but_nonexistent" => "2021-02-01"
        ])
        @test_throws ErrorException(
            "Invalid as_at_date `xxxx-yy-mm`. Date must be in form YYYY-MM-DD."
        ) fetch_series_as_at([
            "ABSCPIQTR" => "2021-02-01", "ABSCPIQTR_SYD_NSA" => "xxxx-yy-mm"
        ])
    end
end
