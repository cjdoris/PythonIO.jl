module Npy

export readnpy, writenpy

const NPY_MAGIC = b"\x93NUMPY"

const BIGENDIAN = ENDIAN_BOM == 0x01020304

"""
    NpyDescr

The descr portion of a .npy header.
"""
struct NpyDescr
    eltype :: DataType
    bigendian :: Bool
end

"""
    NpyHeader

The header portion of a .npy file.
"""
struct NpyHeader
    raw :: String
    version_major :: Int
    version_minor :: Int
    descr :: NpyDescr
    fortran_order :: Bool
    shape :: Vector{Int}
end

"""
    readnpyheader(io::IO) :: NpyHeader

Read the .npy header.
"""
function readnpyheader(io::IO)
    # magic string
    for b in NPY_MAGIC
        if read(io, UInt8) != b
            error("Not a .npy file (incorrect magic string)")
        end
    end

    # version
    version_major = read(io, UInt8)
    version_minor = read(io, UInt8)

    if 1 ≤ version_major ≤ 3
        # header size
        if version_major < 2
            header_size = Int(ltoh(read(io, UInt16)))
        else
            header_size = Int(ltoh(read(io, UInt32)))
        end

        # read header
        raw = String(read(io, header_size))
        sizeof(raw) == header_size || error("reached end of file while reading header")
        version_major < 2 && !isascii(raw) && error("header contains non-ASCII characters")

        # parse header
        descr = nothing
        fortran_order = nothing
        shape = nothing
        i = firstindex(raw)
        i = parse_space(raw, i)
        i, _ = parse_char(raw, i, '{')
        while true
            i = parse_space(raw, i)
            i, c = parse_char(raw, i, '}', nothing)
            c == '}' && break
            i, k = parse_string(raw, i)
            k in ("descr", "fortran_order", "shape") || error("bad header key, got $(repr(k))")
            i = parse_space(raw, i)
            i, _ = parse_char(raw, i, ':')
            i = parse_space(raw, i)
            if k == "descr"
                i, descr = parse_descr(raw, i)
            elseif k == "fortran_order"
                i, fortran_order = parse_fortran_order(raw, i)
            elseif k == "shape"
                i, shape = parse_shape(raw, i)
            else
                @assert false
            end
            i = parse_space(raw, i)
            i, c = parse_char(raw, i, ('}', ','))
            c == '}' && break
        end
        descr === nothing && error("missing key $(repr("descr"))")
        fortran_order === nothing && error("missing key $(repr("fortran_order"))")
        shape === nothing && error("missing key $(repr("shape"))")
        i = parse_space(raw, i)
        checkbounds(Bool, raw, i) && error("expecting end of header, got $(repr(raw[i]))")

        # done
        NpyHeader(strip(raw), version_major, version_minor, descr, fortran_order, shape)

    else
        error("npy version $(version_major).$(version_minor) not supported")
    end
end

function parse_space(s, i)
    while checkbounds(Bool, s, i) && isspace(s[i])
        i = nextind(s, i)
    end
    return i
end

struct Unspecified end

function parse_char(s, i, f::Function, d=Unspecified())
    if checkbounds(Bool, s, i)
        c = s[i]
        if f(c)
            return nextind(s, i), c
        elseif d === Unspecified()
            error("parsing error, got $(repr(c))")
        elseif d isa Function
            return i, d(repr(c))
        else
            return i, d
        end
    elseif d === Unspecified()
        error("parsing error, got $(repr(c))")
    elseif d isa Function
        return i, d("end of file")
    else
        return i, d
    end
end

parse_char(s, i, c::Char, d=x->error("expecting $(repr(c)), got $x")) = parse_char(s, i, x->x==c, d)

parse_char(s, i, cs::Tuple{Vararg{Char}}, d=x->error("expecting $(join(map(repr, cs), ", ", " or ")), got $x")) = parse_char(s, i, x->x in cs, d)

function parse_string(s, i)
    i, q = parse_char(s, i, ('"', '\''))
    cs = Char[]
    while true
        if checkbounds(Bool, s, i)
            c = s[i]
            if c == q
                return nextind(s, i), String(cs)
            elseif c == '\\'
                error("escapes not implemented")
            else
                push!(cs, c)
                i = nextind(s, i)
            end
        else
            error("expecting char, got end of file")
        end
    end
end

function parse_descr(s, i)
    i, str = parse_string(s, i)
    e = str[1]
    e in "<>|" || error("bad descr, got $(repr(str))")
    t = str[2:end]
    if t == "b1"
        T = Bool
    elseif t == "i1"
        T = Int8
    elseif t == "i2"
        T = Int16
    elseif t == "i4"
        T = Int32
    elseif t == "i8"
        T = Int64
    elseif t == "u1"
        T = UInt8
    elseif t == "u2"
        T = UInt16
    elseif t == "u4"
        T = UInt32
    elseif t == "u8"
        T = UInt64
    elseif t == "f2"
        T = Float16
    elseif t == "f4"
        T = Float32
    elseif t == "f8"
        T = Float64
    elseif t == "c4"
        T = ComplexF16
    elseif t == "c8"
        T = ComplexF32
    elseif t == "c16"
        T = ComplexF64
    else
        error("unsupported descr: $(repr(str))")
    end
    if e == '|' && sizeof(T) > 1
        error("invalid descr, got $(repr(str))")
    end
    return i, NpyDescr(T, e == '>')
end

function parse_fortran_order(s, i)
    i, c = parse_char(s, i, ('T', 'F'))
    if c == 'T'
        i, _ = parse_char(s, i, 'r')
        i, _ = parse_char(s, i, 'u')
        i, _ = parse_char(s, i, 'e')
        return i, true
    elseif c == 'F'
        i, _ = parse_char(s, i, 'a')
        i, _ = parse_char(s, i, 'l')
        i, _ = parse_char(s, i, 's')
        i, _ = parse_char(s, i, 'e')
        return i, false
    end
    @assert false
end

function parse_shape(s, i)
    i, _ = parse_char(s, i, '(')
    ans = Int[]
    while true
        i = parse_space(s, i)
        i, c = parse_char(s, i, ')', nothing)
        c == ')' && break
        i, n = parse_int(s, i)
        push!(ans, n)
        i = parse_space(s, i)
        i, c = parse_char(s, i, (')', ','))
        c == ')' && break
    end
    return (i, ans)
end

function parse_int(s, i)
    i, c = parse_char(s, i, x->'0'≤x≤'9', x->error("expecting digit, got $x"))
    n = Int(c - '0')
    while true
        i, c = parse_char(s, i, x->'0'≤x≤'9', nothing)
        c === nothing && break
        n = 10*n + Int(c - '0')
    end
    return i, n
end

"""
    readnpydata(io::IO, h::NpyHeader; transpose::Bool=false)

Read the data portion of a .npy file.

If `transpose=true` then the array is transposed.
"""
function readnpydata(io::IO, h::NpyHeader; transpose::Bool=false)
    fo = h.fortran_order
    dt = h.descr
    sz = h.shape
    if transpose
        fo = !fo
        sz = reverse(sz)
    end
    x = _readarray(io, dt.eltype, Tuple(fo ? sz : reverse(sz)))::Array
    if BIGENDIAN != dt.bigendian && sizeof(st.eltype) > 1
        x = map(bswap, x)::Array
    end
    if !fo
        x = _reversedims(x)::Array
    end
    return x
end

_reversedims(x::AbstractArray{T,N}) where {T,N} = N<2 ? x : permutedims(x, ntuple(i->(N+1-i), N))

function _readarray(io::IO, ::Type{T}, size::NTuple{N,Int}) where {N,T}
    @assert isbitstype(T)
    x = Array{T,N}(undef, size)
    read!(io, x)
    return x
end

"""
    readnpy(io_or_filename; transpose::Bool=false)

Read a .npy array from an IO stream or filename.

If `transpose=true` then the array is transposed.
"""
function readnpy(io::IO; transpose::Bool=false)
    readnpydata(io, readnpyheader(io), transpose=transpose)
end
function readnpy(fn::AbstractString; kw...)
    open(io->readnpy(io; kw...), fn)
end

"""
    writenpy(io_or_filename, x::AbstractArray)

Write a .npy array to an IO stream or filename.
"""
function writenpy(io::IO, x::AbstractArray{T,N}) where {T,N}
    if T == Bool
        t = "b1"
    elseif T == Int8
        t = "i1"
    elseif T == Int16
        t = "i2"
    elseif T == Int32
        t = "i4"
    elseif T == Int64
        t = "i8"
    elseif T == UInt8
        t = "u1"
    elseif T == UInt16
        t = "u2"
    elseif T == UInt32
        t = "u4"
    elseif T == UInt64
        t = "u8"
    elseif T == Float16
        t = "f2"
    elseif T == Float32
        t = "f4"
    elseif T == Float64
        t = "f8"
    elseif T == ComplexF16
        t = "c4"
    elseif T == ComplexF32
        t = "c8"
    elseif T == ComplexF64
        t = "c16"
    else
        error("unsupported eltype: $T")
    end
    e = sizeof(T) == 1 ? '|' : BIGENDIAN ? '>' : '<'
    header = "{'descr': '$e$t', 'fortran_order': True, 'shape': $(Tuple{Vararg{Int}}(size(x)))}"
    if sizeof(header) + 100 > typemax(UInt16)
        version = 3
    else
        version = 1
    end
    curlen = sizeof(NPY_MAGIC) + 2 + (version==1 ? 2 : 4) + sizeof(header) + 1
    npad = mod(-curlen, 64)
    @assert 0 ≤ npad < 64
    @assert mod(curlen + npad, 64) == 0
    write(io, NPY_MAGIC)
    write(io, UInt8(version))
    write(io, UInt8(0))
    if version == 1
        write(io, UInt16(sizeof(header) + npad + 1))
    else
        write(io, UInt32(sizeof(header) + npad + 1))
    end
    write(io, header)
    write(io, ' '^npad)
    write(io, '\n')
    write(io, x)
    return
end
function writenpy(fn::AbstractString, x::AbstractArray)
    open(io->writenpy(io, x), fn, "w")
end

end
