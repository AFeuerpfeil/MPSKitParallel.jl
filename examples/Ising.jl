using Pkg
Pkg.activate("/home/afeuerpfeil/.julia/dev/MPSKitParallel")
using MPSKit
using MPSKitModels
using TensorKit

symmetry = TensorKit.SU2Irrep
spin = 1
J = 1
chain = InfiniteChain(1)
H = heisenberg_XXX(symmetry, chain; J, spin);
physical_space = SU2Space(1 => 1);
virtual_space_inf = Rep[SU₂](1 // 2 => 16, 3 // 2 => 16, 5 // 2 => 8, 7 // 2 => 4);
ψ₀_inf = InfiniteMPS([physical_space], [virtual_space_inf]);
ψ_inf, envs_inf, delta_inf = find_groundstate(ψ₀_inf, H; verbosity = 3);

using MPSKitParallel
using MPI
H_mpi = MPIOperator(H);
MPI.Init()
mpi_rank() = MPI.Comm_rank(MPI.COMM_WORLD)
mpi_size() = MPI.Comm_size(MPI.COMM_WORLD)
println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes.")
ψ_infmpi, envs_infmpi, delta_infmpi = find_groundstate(ψ₀_inf, H_mpi; verbosity = 3);

println("Hey, I am rank=$(mpi_rank()) out of $(mpi_size()) processes. abs(dot(ψ_inf, ψ_infmpi)) = $(abs(dot(ψ_inf, ψ_infmpi)))")