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

Base.IteratorSize(m::AbstractBosonStar) = Base.IteratorSize(m.id)
Base.length(m::AbstractBosonStar) = Base.length(m.id)
Base.isdone(m::AbstractBosonStar) = Base.isdone(m.id)
Base.isdone(m::AbstractBosonStar, state) = Base.isdone(m.id, state)	