using Pkg
Pkg.activate("/home/afeuerpfeil/.julia/dev/MPSKitParallel")
using LinearAlgebra

include("../src/multiprocessing/mpi/mpi_buffers.jl")
using MPI
MPI.Init()
comm = MPI.COMM_WORLD
rank=MPI.Comm_rank(comm)
println("Hello world, I am $(MPI.Comm_rank(comm)) of $(MPI.Comm_size(comm))")
MPI.Barrier(comm)

println("I am $(MPI.Comm_rank(comm)) of $(MPI.Comm_size(comm)), we are now testing the overloaded MPI functions")
println("We begin with small data, so that no chunking is necessary:")
A=rand(10,10)
println("Rank $rank has matrix A with norm $(norm(A))")
if rank!=0
    large_send(A, comm; dest=0, tag=0)
else
    for i in 1:MPI.Comm_size(comm)-1
        A_received=large_receive(comm;source=i, tag=0)
        println("Rank 0 received matrix from rank $i with norm $(norm(A_received))")
    end
end
# println("Now we test big data")
# A=rand(ComplexF64,16000,10000)
# println("Rank $rank has matrix A with norm $(norm(A))")
# if rank!=0
#     large_send(A, comm; dest=0, tag=0)
# else
#     for i in 1:MPI.Comm_size(comm)-1
#         A_received=large_receive(comm;source=i, tag=0)
#         println("Rank 0 received matrix from rank $i with norm $(norm(A_received))")
#     end
# end