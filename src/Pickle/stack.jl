struct Stack
    items :: Vector{Any}
    marks :: Vector{Int}
end

Stack() = Stack([], Int[])

function Base.length(s::Stack)
    length(s.items)
end

function Base.push!(s::Stack, x)
    push!(s.items, x)
    s
end

function Base.pop!(s::Stack)
    pop!(s.items)
end

function poptomark!(s::Stack)
    m = unmark!(s)
    ans = s.items[m+1:end]
    resize!(s.items, m)
    ans
end

function top(s::Stack)
    s.items[end]
end

function mark!(s::Stack)
    push!(s.marks, length(s.items))
    s
end

function unmark!(s::Stack)
    pop!(s.marks)
end

function topmark(s::Stack)
    s.marks[end]
end
