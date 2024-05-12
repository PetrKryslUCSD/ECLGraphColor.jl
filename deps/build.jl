if (Base.Sys.islinux())
    # -fPIC -shared for a shared library
    run(`g++ -O3 -march=native -fPIC -shared -fopenmp ECL-GC_12-lib.cpp -o ecl-gc.so`)
elseif (Base.Sys.isapple())
    # -fPIC -shared for a shared library
    run(`clang++ -O3 -march=native -fPIC -shared -fopenmp ECL-GC_12-lib.cpp -o ecl-gc.so`)
else
    @warn "Architecture not supported (so far only Linux and Apple (armclang++ + libomp))."
end