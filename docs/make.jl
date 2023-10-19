using Documenter, Aeconomica

makedocs(
    modules = [Aeconomica],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "aeconomica",
    sitename = "Aeconomica.jl",
    pages = Any[
        "index.md",
        "Reference" => "reference.md"
    ]
)

deploydocs(
    repo = "github.com/aeconomica/Aeconomica.jl.git",
    push_preview = true,
    devbranch = "main"
)
