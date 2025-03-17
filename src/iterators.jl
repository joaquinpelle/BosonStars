function Base.iterate(m::SBS{T}) where {T<:CollectiveId}
    it = Base.iterate(m.id)
    it === nothing && return it
    item, state = it
    return SBS(item), state
end

function Base.iterate(m::SBS{T}, state) where {T<:CollectiveId} 
    it = Base.iterate(m.id, state)
    it === nothing && return it
    next_item, next_state = it
    return SBS(next_item), next_state
end

function Base.iterate(m::LBS{T}) where {T<:CollectiveId}
    it = Base.iterate(m.id)
    it === nothing && return it
    item, state = it
    return LBS(item), state
end

function Base.iterate(m::LBS{T}, state) where {T<:CollectiveId} 
    it = Base.iterate(m.id, state)
    it === nothing && return it
    next_item, next_state = it
    return LBS(next_item), next_state
end

function Base.iterate(m::ABS{T}) where {T<:CollectiveId}
    it = Base.iterate(m.id)
    it === nothing && return it
    item, state = it
    return ABS(item), state
end

function Base.iterate(m::ABS{T}, state) where {T<:CollectiveId} 
    it = Base.iterate(m.id, state)
    it === nothing && return it
    next_item, next_state = it
    return ABS(next_item), next_state
end

Base.IteratorSize(m::AbstractBosonStar) = Base.IteratorSize(m.id)
Base.length(m::AbstractBosonStar) = Base.length(m.id)
Base.isdone(m::AbstractBosonStar) = Base.isdone(m.id)
Base.isdone(m::AbstractBosonStar, state) = Base.isdone(m.id, state)	

Base.getindex(m::AbstractModel, i::Int) = Base.getindex(iscollective(m), m, i)
Base.getindex(::IsCollective, m::SBS, i::Int) = SBS(m.id[i])
Base.getindex(::IsCollective, m::LBS, i::Int) = LBS(m.id[i])
Base.getindex(::IsCollective, m::ABS, i::Int) = ABS(m.id[i])
Base.getindex(::IsNotCollective, m::AbstractModel, i) = m
Base.size(m::AbstractBosonStar) = Base.size(m.id)