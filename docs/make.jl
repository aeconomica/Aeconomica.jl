using Documenter, Aeconomica

makedocs(
    modules = [Aeconomica],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "aeconomica",
    sitename = "Aeconomica.jl",
    pages = Any["index.md"],
    # strict = true,
    # clean = true,
    checkdocs = :exports
)

deploydocs(
    repo = "github.com/aeconomica/Aeconomica.jl.git",
    push_preview = true,
    devbranch = "main"
)
