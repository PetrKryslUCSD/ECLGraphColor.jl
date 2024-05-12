# ECLGraphColor.jl

Julia wrapper of the C++ implementation of the graph colouring algorithm
[ECL-GC](https://userweb.cs.txstate.edu/~burtscher/research/ECL-GC/) with
shortcutting by M. Burtscher and his coworkers.

## Limitations

The library has been thoroughly tested on various Linux machines.
The assumption is that `g++` is capable of compiling OpenMP programs.

The library at the moment does not compile on Windows. 

The library compiles on the Mac using the homebrew `clang++` (18.1.5 should be good).

## Example

From the paper by G. Alabandi, E. Powers, and M. Burtscher. "Increasing the Parallelism of Graph Coloring via Shortcutting." Proceedings of the 2020 ACM Conference on Principles and Practice of Parallel Programming, pp. 262-275. February 2020.
```
    using Test
    using ECLGraphColor: PECLgraph, make_graph, add_nlist, add_nindex
    using ECLGraphColor: get_color, run_graph_coloring, free_graph
    using ECLGraphColor: print_graph, write_graph, read_graph
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
    g = read_graph("testgraph.egr")
    run_graph_coloring(g, 4, 1, 1)
    
    free_graph(g)
```