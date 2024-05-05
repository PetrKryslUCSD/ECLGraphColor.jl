module mbas001
using Test
using ECLGraphColor: PECLgraph, make_graph, add_nlist, add_nindex
using ECLGraphColor: get_color, run_graph_coloring, free_graph, print_graph
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
    for i in 1:length(crs)
        add_nindex(g, i, idx)
        idx += length(crs[i])
    end
    add_nindex(g, length(crs)+1, idx)
    for i in 1:length(crs)
        for j in 1:length(crs[i])
            add_nlist(g, i, j, crs[i][j])
        end
    end
    print_graph(g)
    run_graph_coloring(g, 4)
    for i in 1:length(crs)
        @show get_color(g, i)
    end

    @test 1 == 1
    true
end
test()
nothing
end
