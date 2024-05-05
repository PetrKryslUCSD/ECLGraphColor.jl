using Libdl
_LIBDIR = joinpath(@__DIR__, ".", )
_LIB = dlopen(joinpath(_LIBDIR, "ecl-gc") * ".so")
dlsym(_LIB, :make_graph)

struct PECLgraph
    p::Ptr{Cvoid}
end

function make_graph(nodes::T, edges::T) where {T}
    return PECLgraph(ccall(dlsym(_LIB, :make_graph),
        Ptr{Cvoid},
        (Cuint, Cuint),
        nodes, edges))
end

g = make_graph(10, 20)

dlclose(_LIB)