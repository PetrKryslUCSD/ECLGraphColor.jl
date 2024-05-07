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

    function size_of_int()
        return ccall(dlsym(_LIB, :size_of_int),
        Cint,
        (),)
    end

    const IntType = size_of_int() == 4 ? Int32 : Int64

    function int_type()
        return IntType
    end

    function make_graph(nodes::T, edges::T) where {T}
        return PECLgraph(ccall(dlsym(_LIB, :make_graph),
            Ptr{Cvoid},
            (Cint, Cint),
            IntType(nodes), IntType(edges)))
    end

    const dlsym_add_nlist = dlsym(_LIB, :add_nlist)

    function add_nlist(g::PECLgraph, row::T, serialnum::T, neighbor::T) where {T}
        return ccall(dlsym_add_nlist, 
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint, Cint),
            g.p, IntType(row), IntType(serialnum), IntType(neighbor))
    end

    # add_nlist_all_row(ECLgraph *g, int row, int howmany, int neighbors[])
    const dlsym_add_nlist_all_row = dlsym(_LIB, :add_nlist_all_row)

    function add_nlist_all_row(g::PECLgraph, 
        row::T, howmany::T, neighbors::Vector{IT}) where {T, IT<:IntType}
        return ccall(dlsym_add_nlist_all_row, 
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint, Ref{Cint}),
            g.p, IntType(row), IntType(howmany), neighbors)
    end

    const dlsym_add_nindex = dlsym(_LIB, :add_nindex)

    function add_nindex(g::PECLgraph, row::T, idx::T) where {T}
        return ccall(dlsym_add_nindex,
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint),
            g.p, IntType(row), IntType(idx))
    end

    const dlsym_get_color = dlsym(_LIB, :get_color)

    function get_color(g::PECLgraph, row::T) where {T}
        return ccall(dlsym_get_color, 
            Cint,
            (Ptr{Cvoid}, Cint),
            g.p, IntType(row))
    end

    function run_graph_coloring(g::PECLgraph, threads::T, test::T=0, verbose::T=0) where {T}
        return ccall(dlsym(_LIB, :run_graph_coloring),
            Cvoid,
            (Ptr{Cvoid}, Cint, Cint, Cint,),
            g.p, IntType(threads), IntType(test), IntType(verbose))
    end

    function print_graph(g::PECLgraph)
        return ccall(dlsym(_LIB, :print_graph),
            Cvoid,
            (Ptr{Cvoid},),
            g.p,)
    end

    function write_graph(g::PECLgraph, fname::String)
        return ccall(dlsym(_LIB, :write_graph),
            Cvoid,
            (Ptr{Cvoid}, Cstring),
            g.p, fname)
    end

    function read_graph(fname::String) 
        return PECLgraph(ccall(dlsym(_LIB, :read_graph),
            Ptr{Cvoid},
            (Cstring, ),
            fname))
    end

    function free_graph(g::PECLgraph)
        return ccall(dlsym(_LIB, :free_graph),
            Cvoid,
            (Ptr{Cvoid},),
            g.p,)
    end

else # Not Linux: all functions are no ops

    function int_type()
        return Int
    end

    function make_graph(nodes::T, edges::T) where {T}
        PECLgraph(Ptr{Cvoid}(0))
    end

    function add_nlist(g::PECLgraph, row::T, serialnum::T, neighbor::T) where {T}
    end

    function add_nlist_all_row(g::PECLgraph, 
        row::T, howmany::T, neighbors::Vector{IT<:IntType}) where {T}
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

    function write_graph(g::PECLgraph, fname::String)
    end

    function read_graph(fname::String) 
        PECLgraph(Ptr{Cvoid}(0))
    end


    function free_graph(g::PECLgraph)
    end

end

end # module ECLGraphColor
