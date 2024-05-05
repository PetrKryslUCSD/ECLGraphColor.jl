module ECLGraphColor

using Libdl

# Do not pre compile, since we are using a shared library
__precompile__(false) # 

const _LIBDIR = joinpath(@__DIR__, "..", "deps")
const _LIB = dlopen(joinpath(_LIBDIR, "ecl-gc") * ".so")

struct PECLgraph
    p::Ptr{Cvoid}
end

function make_graph(nodes::T, edges::T) where {T}
    return PECLgraph(ccall(dlsym(_LIB, :make_graph),
        Ptr{Cvoid},
        (Cint, Cint),
        nodes, edges))
end

function add_nlist(g::PECLgraph, row::T, serialnum::T, neighbor::T) where {T}
    return ccall(dlsym(_LIB, :add_nlist),
        Cvoid,
        (Ptr{Cvoid}, Cint, Cint, Cint),
        g.p, row, serialnum, neighbor)
end

function add_nindex(g::PECLgraph, row::T, idx::T) where {T}
    return ccall(dlsym(_LIB, :add_nindex),
        Cvoid,
        (Ptr{Cvoid}, Cint, Cint),
        g.p, row, idx)
end

function get_color(g::PECLgraph, row::T) where {T}
    return ccall(dlsym(_LIB, :get_color),
        Cint,
        (Ptr{Cvoid}, Cint),
        g.p, row)
end

function run_graph_coloring(g::PECLgraph, threads::T, test::T = 0, verbose::T = 0) where {T}
    return ccall(dlsym(_LIB, :run_graph_coloring),
        Cvoid,
        (Ptr{Cvoid}, Cint, Cint, Cint,),
        g.p, threads, test, verbose)
end

function print_graph(g::PECLgraph) 
    return ccall(dlsym(_LIB, :print_graph),
        Cvoid,
        (Ptr{Cvoid},),
        g.p,)
end

function free_graph(g::PECLgraph) 
    return ccall(dlsym(_LIB, :free_graph),
        Cvoid,
        (Ptr{Cvoid},),
        g.p,)
end

end # module ECLGraphColor
