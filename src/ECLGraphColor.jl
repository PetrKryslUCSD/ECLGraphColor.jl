module ECLGraphColor

using Libdl

# Do not pre compile, since we are using a shared library
__precompile__(false) # 

struct PECLgraph
    p::Ptr{Cvoid}
end

if (Base.Sys.islinux())
    const _LIBDIR = joinpath(@__DIR__, "..", "deps")
    const _LIB = dlopen(joinpath(_LIBDIR, "ecl-gc") * ".so")

    function make_graph(nodes::T, edges::T) where {T}
        return PECLgraph(ccall(dlsym(_LIB, :make_graph),
            Ptr{Cvoid},
            (Cint, Cint),
            nodes, edges))
    end

    const dlsym_add_nlist = dlsym(_LIB, :add_nlist)

    function add_nlist(g::PECLgraph, row::T, serialnum::T, neighbor::T) where {T}
        return ccall(dlsym_add_nlist, 
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint, Cint),
            g.p, row, serialnum, neighbor)
    end

    const dlsym_add_nindex = dlsym(_LIB, :add_nindex)

    function add_nindex(g::PECLgraph, row::T, idx::T) where {T}
        return ccall(dlsym_add_nindex,
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint),
            g.p, row, idx)
    end

    const dlsym_get_color = dlsym(_LIB, :get_color)

    function get_color(g::PECLgraph, row::T) where {T}
        return ccall(dlsym_get_color, 
            Cint,
            (Ptr{Cvoid}, Cint),
            g.p, row)
    end

    function run_graph_coloring(g::PECLgraph, threads::T, test::T=0, verbose::T=0) where {T}
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

else # Not Linux: all functions are no ops

    function make_graph(nodes::T, edges::T) where {T}
        PECLgraph(Ptr{Cvoid}(0))
    end

    function add_nlist(g::PECLgraph, row::T, serialnum::T, neighbor::T) where {T}
    end

    function add_nindex(g::PECLgraph, row::T, idx::T) where {T}
    end

    function get_color(g::PECLgraph, row::T) where {T}
        0
    end

    function run_graph_coloring(g::PECLgraph, threads::T, test::T=0, verbose::T=0) where {T}
    end

    function print_graph(g::PECLgraph)
    end

    function free_graph(g::PECLgraph)
    end

end

end # module ECLGraphColor
