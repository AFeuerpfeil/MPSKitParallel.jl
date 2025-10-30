@forward_astype SharedInfiniteMPS.parent Base.repeat, Base.circshift
@forward SharedInfiniteMPS.parent MPSKit.each_site, MPSKit.r_RL, MPSKit.l_LR
# function Base.repeat(ψ::SharedInfiniteMPS, n::Integer)
#     return SharedInfiniteMPS(repeat(parent(ψ), n))
# end
# function Base.circshift(ψ::SharedInfiniteMPS, n::Integer)
#     return SharedInfiniteMPS(circshift(parent(ψ), n))
# end

# MPSKit.eachsite(ψ::SharedInfiniteMPS) = MPSKit.each_site(parent(ψ))

# MPSKit.r_RL(ψ::SharedInfiniteMPS, site::Int) = MPSKit.r_RL(parent(ψ), site)
# MPSKit.l_LR(ψ::SharedInfiniteMPS, site::Int) = MPSKit.l_LR(parent(ψ), site)