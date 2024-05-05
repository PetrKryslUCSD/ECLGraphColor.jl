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

function run_graph_coloring(g::PECLgraph, threads::T) where {T}
    return ccall(dlsym(_LIB, :run_graph_coloring),
        Cvoid,
        (Ptr{Cvoid}, Cint,),
        g.p, threads)
end

function free_graph(g::PECLgraph) 
    return ccall(dlsym(_LIB, :free_graph),
        Cvoid,
        (Ptr{Cvoid},),
        g.p,)
end

A, B, C, D, E, F, G = 1, 2, 3, 4, 5, 6, 7

crs = fill([], 7)
# crs[A] =  [A, B, D, F, G, E]
# crs[B] =  [B, A, D, C, E, G]
# crs[C] =  [C, G, B, D, E, F]
# crs[D] =  [D, A, F, E, C, B]
# crs[E] =  [E, D, F, C, B, A]
# crs[F] =  [F, D, E, C, A]
# crs[G] =  [G, B, C, A]
crs[A] =  [B, D, F, G, E]
crs[B] =  [A, D, C, E, G]
crs[C] =  [G, B, D, E, F]
crs[D] =  [A, F, E, C, B]
crs[E] =  [D, F, C, B, A]
crs[F] =  [D, E, C, A]
crs[G] =  [B, C, A]

let
    g = make_graph(length(crs), sum([length(c) for c in crs]))
    idx = 1
    for i in 1:length(crs)
        add_nindex(g, i, idx)
        idx += length(crs[i])
    end
    for i in 1:length(crs)
        for j in 1:length(crs[i])
            add_nlist(g, i, j, crs[i][j])
        end
    end
    run_graph_coloring(g, 4)
    for i in 1:length(crs)
        @show get_color(g, i)
    end
end


# free_graph(g)

# dlclose(_LIB)