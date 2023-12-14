function check_valid_code(code)
    return occursin(r"^[\sa-zA-Z0-9_]+$", code) ||
        throw(ErrorException("`$code` is not a valid series code"))
end

function check_valid_date(date)
    return occursin(r"\d{4}-\d{2}-\d{2}", date) && length(date) == 10
end

function check_valid_as_at_date(date)
    return check_valid_date(date) || throw(
        ErrorException("Invalid as_at_date `$date`. Date must be in form YYYY-MM-DD.")
    )
end

function check_valid_vintage(vintage)
    return (
        vintage == "current" ||
        vintage == "latest" ||
        vintage == "previous" ||
        check_valid_date(vintage)
    ) || throw(
        ErrorException(
            "Invalid vintage `$vintage`. Options are a date (in form YYYY-MM-DD) or one of `current` (alias `latest`) or `previous`",
        ),
    )
end
