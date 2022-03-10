import ZipFile

export NpzReader, NpzWriter, readnpz, writenpz

"""
    NpzReader(io::IO; own=false)
    NpzReader(fn::AbstractString)

Open the given .npz file for reading.

- `keys(reader)` returns the available keys.
- `readnpy(reader, key)` or `reader[key]` returns the array at the given key.
- `close(reader)` closes the underlying IO stream.
"""
struct NpzReader
    zipreader::ZipFile.Reader
    items::Dict{String,ZipFile.ReadableFile}
    function NpzReader(zr::ZipFile.Reader)
        items = Dict{String,ZipFile.ReadableFile}()
        for file in zr.files
            if endswith(file.name, ".npy")
                items[file.name[1:end-4]] = file
            else
                @debug "ignoring .npz entry" file.name
            end
        end
        new(zr, items)
    end
end

NpzReader(io::IO; own::Bool=false) = NpzReader(ZipFile.Reader(io, own))

NpzReader(fn::AbstractString) = NpzReader(ZipFile.Reader(fn))

Base.keys(r::NpzReader) = keys(r.items)

Base.close(r::NpzReader) = close(r.zipreader)

"""
    readnpy(r::NpzReader, k::AbstractString; transpose=false)

Return the array at key `k` from reader `r`.

Equivalent to `r[k; ...]`.
"""
function readnpy(r::NpzReader, k::AbstractString; kw...)
    f = r.items[k]
    seekstart(f)
    return readnpy(f; kw...)
end

"""
    readnpyheader(r::NpzReader, k::AbstractString)

Return the .npy header at key `k` from reader `r`.
"""
function readnpyheader(r::NpzReader, k::AbstractString; kw...)
    f = r.items[k]
    seekstart(f)
    return readnpyheader(f; kw...)
end

Base.getindex(r::NpzReader, k::AbstractString; kw...) = readnpy(r, k; kw...)

function Base.show(io::IO, ::MIME"text/plain", r::NpzReader)
    ks = sort(collect(keys(r)))
    print(io, "NpzReader with $(length(ks)) entries")
    if !isempty(ks)
        print(io, ":")
        for k in ks
            println(io)
            print(io, " ")
            show(io, k)
            print(io, " => ")
            h = readnpyheader(r, k)
            print(io, Base.dims2string(h.shape), " ")
            T = Array{h.descr.eltype, length(h.shape)}
            show(io, T)
        end
    end
end

"""
    readnpz(io_or_filename, [key_or_keys]; transpose=false)

Read arrays from a .npz file.

Returns a `Dict` of all arrays by default. The second argument can select a subset of keys
or a single key.
"""
function readnpz(src::Union{IO,AbstractString}, ks=nothing; kw...)
    readnpz(src) do r
        if ks isa AbstractString
            return readnpy(r, ks; kw...)
        else
            return Dict(k => readnpy(r, k; kw...) for k in (ks === nothing ? keys(r) : ks))
        end
    end
end

"""
    readnpz(f::Function, io_or_filename)

Open a .npz file and return `f(reader::NpzReader)`.
"""
function readnpz(f::Function, io::IO)
    return f(NpzReader(io))
end
function readnpz(f::Function, fn::AbstractString)
    r = NpzReader(fn)
    try
        return f(r)
    finally
        close(r)
    end
end

"""
    NpzWriter(io::IO; own=false)
    NpzWriter(fn::AbstractString)

Open the given .npz file for writing.

- `keys(writer)` returns the written keys.
- `writenpy(writer, key, array)` or `writer[key] = array` writes the given array.
- `close(writer)` closes the underlying IO stream.
"""
struct NpzWriter
    zipwriter::ZipFile.Writer
    items::Dict{String,ZipFile.WritableFile}
    function NpzWriter(zw::ZipFile.Writer)
        items = Dict{String,ZipFile.WritableFile}()
        new(zw, items)
    end
end

NpzWriter(io::IO; own::Bool=false) = NpzWriter(ZipFile.Writer(io, own))

NpzWriter(fn::AbstractString) = NpzWriter(ZipFile.Writer(fn))

"""
    writenpy(w::NpzWriter, k::AbstractString, x::AbstractArray; compress=false)

Write the array `x` to writer `w` at key `k`.

Equivalent to `w[k] = x`.
"""
function writenpy(w::NpzWriter, k::AbstractString, x::AbstractArray; compress::Bool=false, kw...)
    k = convert(String, k)
    method = compress ? ZipFile.Deflate : ZipFile.Store
    f = ZipFile.addfile(w.zipwriter, "$(k).npy", method=method)
    w.items[k] = f
    writenpy(f, x; kw...)
    close(f)
    return
end

function Base.setindex!(w::NpzWriter, x::AbstractArray, k::AbstractString; kw...)
    writenpy(w, k, x; kw...)
    return w
end

Base.keys(w::NpzWriter) = keys(w.items)

Base.length(w::NpzWriter) = length(keys(w))

Base.close(w::NpzWriter) = close(w.zipwriter)

function Base.show(io::IO, ::MIME"text/plain", w::NpzWriter)
    ks = sort(collect(keys(w)))
    print(io, "NpzWriter with $(length(ks)) items")
    if !isempty(ks)
        print(io, ":")
        for k in ks
            println(io)
            print(io, " ")
            show(io, k)
            print(io, " => ...")
        end
    end
end

"""
    writenpz(io_or_fn, arrays::Dict; compress=false)
    writenpz(io_or_fn, arrays::Pair...; compress=false)

Write the given arrays to a .npz file.

Any iterable of `Pair{<:AbstractString,<:AbstractArray}` can be written.
"""
function writenpz(src, arrays; kw...)
    writenpz(src) do w
        for (k, v) in arrays
            writenpy(w, k, v; kw...)
        end
    end
end
writenpz(src, arrays::Pair...; kw...) = writenpz(src, arrays; kw...)

"""
    writenpz(f::Function, io_or_filename)

Open a .npz file for writing and return `f(writer::NpzWriter)`.
"""
function writenpz(f::Function, io::IO)
    return f(NpzWriter(io))
end

function writenpz(f::Function, fn::AbstractString)
    w = NpzWriter(fn)
    try
        return f(w)
    finally
        close(w)
    end
end
