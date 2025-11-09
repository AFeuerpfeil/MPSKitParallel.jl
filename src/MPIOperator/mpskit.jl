
MPIOperator(parent::FiniteMPO, reduction::F=Base.:+, comm::C=[MPI.Comm_dup(MPI.COMM_WORLD) for _ in eachsite(parent)]) where {F, C} = MPIOperator{FiniteMPO, F, C}(parent, reduction, comm)

MPIOperator(parent::O, reduction::F=Base.:+, comm::C=MPSKit.PeriodicVector([MPI.Comm_dup(MPI.COMM_WORLD) for _ in eachsite(parent)])) where {O <: InfiniteMPO, F, C} = MPIOperator{O, F, C}(parent, reduction, comm)

MPIOperator(parent::O, reduction::F=Base.:+, comm::C=MPSKit.PeriodicVector([MPI.Comm_dup(MPI.COMM_WORLD) for _ in eachsite(parent)])) where {O <: InfiniteMPOHamiltonian, F, C} = MPIOperator{O, F, C}(parent, reduction, comm)