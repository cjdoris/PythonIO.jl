module Python

export readpy

using ..PyObjects

mutable struct State
    buf::String
    pos::Int
    posend::Int
end

State(buf::String) = State(buf, firstindex(buf), lastindex(buf))

"""
    readpy(io_or_filename; simplify=false)

Reads a single expression from a .py file.
"""
function readpy(io::IO; simplify=nothing)
    ans = parse_any(State(read(io, String)))
    if simplify !== nothing
        ans = PyObjects.simplify(ans)
        ans = PyObjects.walk(simplify, ans)
    end
    return ans
end
readpy(fn::AbstractString; kw...) = open(io->readpy(io; kw...), fn)

function inc(s::State)
    s.pos = nextind(s.buf, s.pos)
    return
end

function char(s::State)
    return s.buf[s.pos]
end

function atend(s::State)
    return s.pos > s.posend
end

function skip_space(s::State)
    while isspace(char(s))
        inc(s)
    end
end

function parse_any(s::State)
    i = skip_space(s)
    c = char(s)
    if ('a' ≤ c ≤ 'z') || ('A' ≤ c ≤ 'Z') || (c == '_')
        ident = parse_ident(s)
        if ident == "True"
            return true
        elseif ident == "False"
            return false
        elseif ident == "None"
            return nothing
        else
            error("not implemented: ident $(repr(ident))")
        end
    elseif c == ''' || c == '"'
        return parse_str(s)
    elseif c == '['
        return parse_list(s)
    elseif c == '('
        return parse_tuple(s)
    elseif c == '{'
        return parse_dict_or_set(s)
    elseif ('0' ≤ c ≤ '9') || (c == '-') || (c == '+') || (c == '.')
        return parse_number(s)
    else
        error("unexpected char: $(repr(c))")
    end
end

function parse_ident(s::State)
    i0 = i1 = s.pos
    inc(s)
    while !atend(s)
        c = char(s)
        if isletter(c) || isnumeric(c) || (c == '_')
            i1 = s.pos
            inc(s)
        else
            break
        end
    end
    return SubString(s.buf, i0:i1)
end

function parse_str(s::State)
    # TODO: triple-quotes
    c0 = char(s)
    inc(s)
    io = IOBuffer()
    while true
        c = char(s)
        inc(s)
        if c == c0
            break
        elseif c == '\\'
            error("escapes not implemented")
        else
            write(io, c)
        end
    end
    return String(take!(io))
end

function parse_list(s::State)
    xs = Any[]
    inc(s)
    while true
        skip_space(s)
        c = char(s)
        if c == ']'
            inc(s)
            break
        else
            x = parse_any(s)
            push!(xs, x)
            skip_space(s)
            c = char(s)
            if c == ','
                inc(s)
            elseif c == ']'
                inc(s)
                break
            else
                error("unexpected $(repr(c)), expecting ',' or ']'")
            end
        end
    end
    return PyList(xs)
end

function parse_tuple(s::State)
    xs = Any[]
    inc(s)
    while true
        skip_space(s)
        c = char(s)
        if c == ')'
            inc(s)
            break
        else
            x = parse_any(s)
            push!(xs, x)
            skip_space(s)
            c = char(s)
            if c == ','
                inc(s)
            elseif c == ')'
                inc(s)
                break
            else
                error("unexpected $(repr(c)), expecting ',' or ')'")
            end
        end
    end
    return PyTuple(xs)
end

function parse_dict_or_set(s::State)
    inc(s)
    skip_space(s)
    c = char(s)
    if c == '}'
        inc(s)
        return PyDict()
    else
        x0 = parse_any(s)
        skip_space(s)
        c = char(s)
        if c == '}'
            inc(s)
            return PySet(Any[x0])
        elseif c == ','
            inc(s)
            xs = Any[x0]
            while true
                skip_space(s)
                c = char(s)
                if c == '}'
                    inc(s)
                    break
                else
                    x = parse_any(s)
                    push!(xs, x)
                    skip_space(s)
                    c = char(s)
                    if c == ','
                        inc(s)
                    elseif c == '}'
                        inc(s)
                        break
                    else
                        error("unexpected $(repr(c)), expecting ',' or '}'")
                    end
                end
            end
            return PySet(xs)
        elseif c == ':'
            inc(s)
            k0 = x0
            skip_space(s)
            v0 = parse_any(s)
            xs = Pair{Any,Any}[Pair{Any,Any}(k0, v0)]
            skip_space(s)
            c = char(s)
            if c == ','
                inc(s)
                while true
                    skip_space(s)
                    c = char(s)
                    if c == '}'
                        inc(s)
                        break
                    else
                        k = parse_any(s)
                        skip_space(s)
                        c = char(s)
                        c == ':' || error("unexpected $(repr(c)), expecting ':'")
                        inc(s)
                        v = parse_any(s)
                        push!(xs, Pair{Any,Any}(k, v))
                        skip_space(s)
                        c = char(s)
                        if c == ','
                            inc(s)
                        elseif c == '}'
                            inc(s)
                            break
                        else
                            error("unexpected $(repr(c)), expecting ',' or '}'")
                        end
                    end
                end
            elseif c == '}'
                inc(s)
            else
                error("unexpected $(repr(c)), expecting ',' or '}'")
            end
            return PyDict(xs)
        else
            error("unexpected $(repr(c)), expecting ',', '}' or ':'")
        end
    end
end

function parse_number(s::State)
    i0 = i1 = s.pos
    inc(s)
    while !atend(s)
        c = char(s)
        if ('0' ≤ c ≤ '9') || (c == '-') || (c == '+') || (c == '.') || ('a' ≤ c ≤ 'f') || ('A' ≤ c ≤ 'F') || (c == 'x') || (c == 'X') || (c == 'b') || (c == 'B') || (c == 'o') || (c == 'O')
            i1 = s.pos
            inc(s)
        else
            break
        end
    end
    x = SubString(s.buf, i0:i1)
    if startswith(x, "0x") || startswith(x, "0o") || startswith(x, "0b")
        y = parse(BigInt, x)
    elseif ('.' in x) || ('e' in x) || ('f' in x)
        y = parse(Float64, x)
    else
        y = parse(BigInt, x)
    end
    if y isa BigInt
        y1 = mod(y, Int)
        if y1 == y
            y = y1
        end
    end
    return y
end

end
