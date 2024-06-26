module mbas001
using Test
using ECLGraphColor
using ECLGraphColor: PECLgraph, make_graph, add_nlist, add_nindex, add_nlist_all_row
using ECLGraphColor: get_color, run_graph_coloring, free_graph
using ECLGraphColor: print_graph, write_graph, read_graph
function test()
    A, B, C, D, E, F, G = 1, 2, 3, 4, 5, 6, 7
    crs = fill([], 7)
    crs[A] = [B, D, F, G, E]
    crs[B] = [A, D, C, E, G]
    crs[C] = [G, B, D, E, F]
    crs[D] = [A, F, E, C, B]
    crs[E] = [D, F, C, B, A]
    crs[F] = [D, E, C, A]
    crs[G] = [B, C, A]
    for i in 1:length(crs)
        crs[i] = sort(crs[i])
    end

    g = make_graph(length(crs), sum([length(c) for c in crs]))
    idx = 1
    for i in eachindex(crs)
        add_nindex(g, i, idx)
        idx += length(crs[i])
    end
    add_nindex(g, length(crs)+1, idx)
    for i in eachindex(crs)
        for j in eachindex(crs[i])
            add_nlist(g, i, j, crs[i][j])
        end
    end
    print_graph(g)
    run_graph_coloring(g, 4, 1, 1)
    shouldget = [
        3
        4
        3
        1
        2
        4
        1]
    for i in 1:length(crs)
        @test get_color(g, i) == shouldget[i]
    end

    write_graph(g, "testgraph.egr")
    free_graph(g)

    g = read_graph("testgraph.egr")
    run_graph_coloring(g, 4, 1, 1)
    
    free_graph(g)

    g = make_graph(length(crs), sum([length(c) for c in crs]))
    idx = 1
    for i in eachindex(crs)
        add_nindex(g, i, idx)
        idx += length(crs[i])
    end
    add_nindex(g, length(crs)+1, idx)
    for i in eachindex(crs)
        add_nlist_all_row(g, i, length(crs[i]), ECLGraphColor.IntType.(crs[i]))
    end
    print_graph(g)
    run_graph_coloring(g, 4, 1, 1)
    shouldget = [
        3
        4
        3
        1
        2
        4
        1]
    for i in 1:length(crs)
        @test get_color(g, i) == shouldget[i]
    end

    write_graph(g, "testgraph.egr")
    free_graph(g)

    true
end
if !((Base.Sys.islinux()) || (Base.Sys.isapple())) # Linux or MacOS
    @warn "Architecture not supported (so far only Linux or Apple)."
else
    test()
end

nothing
end
