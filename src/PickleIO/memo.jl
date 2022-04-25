struct Memo
    items :: Vector{Any}
end
Memo() = Memo([])

function Base.push!(m::Memo, x)
    push!(m.items, x)
end

function Base.getindex(m::Memo, i::Integer)
    m.items[UInt(i)+UInt(1)]
end

function Base.setindex!(m::Memo, v, i::Integer)
    j = UInt(i) + UInt(1)
    length(m.items) < j && resize!(m.items, j)
    m.items[j] = v
    m
end
