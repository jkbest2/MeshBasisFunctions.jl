using MeshBasisFunctions
using Documenter

DocMeta.setdocmeta!(MeshBasisFunctions, :DocTestSetup, :(using MeshBasisFunctions); recursive=true)

makedocs(;
    modules=[MeshBasisFunctions],
    authors="Sam Urmy <oceanographerschoice@gmail.com>, John K Best <isposdef@gmail.com>",
    repo="https://github.com/jkbest2/MeshBasisFunctions.jl/blob/{commit}{path}#{line}",
    sitename="MeshBasisFunctions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jkbest2.github.io/MeshBasisFunctions.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jkbest2/MeshBasisFunctions.jl",
    devbranch="main",
)
