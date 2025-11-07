using Pkg
Pkg.activate("/home/afeuerpfeil/.julia/dev/MPSKitParallel")
using MPSKit
using MPSKitModels
using TensorKit
using MPSKitParallel
using MPIHelper
using MPI
MPSKit.Defaults.set_scheduler!(:serial)

MPI.Init()
mpi_rank() = MPI.Comm_rank(MPI.COMM_WORLD)
mpi_size() = MPI.Comm_size(MPI.COMM_WORLD)

N=4
J2=0.3
H_J1 = @mpoham sum(S_exchange(;spin=1//2){i, j} for (i, j) in nearest_neighbours(InfiniteChain(N)));
H_J2 = @mpoham sum(rmul!(S_exchange(;spin=1//2){i, j}, J2) for (i, j) in next_nearest_neighbours(InfiniteChain(N)));

H_J1J2 = H_J1 + H_J2;
state = InfiniteMPS(fill(2, N), fill(20, N));
state = MPIHelper.bcast(state, MPI.COMM_WORLD)


ψ_inf, envs, delta = find_groundstate(
    state, H_J1J2, VUMPS(; maxiter = 20, tol = 1.0e-12, verbosity=1)
);

if mpi_rank() == 0
    H_mpi = @mpoham sum(S_exchange(;spin=1//2){i, j} for (i, j) in nearest_neighbours(InfiniteChain(N)));
elseif mpi_rank() == 1
    H_mpi = @mpoham sum(rmul!(S_exchange(;spin=1//2){i, j}, J2) for (i, j) in next_nearest_neighbours(InfiniteChain(N)));
else
    error("This example only works with 2 MPI processes.")
end
H_mpi = MPIOperator(H_mpi)


println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes.")

ψ_infmpi, envs_infmpi, delta_infmpi = find_groundstate(state, H_mpi, verbosity=1);  ## This tests VUMPS and GradientGrassmann

println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes. abs(dot(ψ_inf, ψ_infmpi)) = $(abs(dot(ψ_inf, ψ_infmpi)))")

ψ_infmpi, envs_infmpi, delta_infmpi = find_groundstate(state, H_mpi, IDMRG2(; maxiter = 20, tol = 1.0e-12, verbosity=1, trscheme=truncrank(50)));

println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes. abs(dot(ψ_inf, ψ_infmpi)) = $(abs(dot(ψ_inf, ψ_infmpi)))")

ψ_infmpi, envs_infmpi, delta_infmpi = find_groundstate(state, H_mpi, IDMRG(; maxiter = 20, tol = 1.0e-12, verbosity=1));

println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes. abs(dot(ψ_inf, ψ_infmpi)) = $(abs(dot(ψ_inf, ψ_infmpi)))")

