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
