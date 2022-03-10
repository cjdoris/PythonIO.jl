"""
    module Pickle

Functions to read and write Python pickle files.
"""
module Pickle

export readpkl

# We use the following as a reference:
# https://formats.kaitai.io/python_pickle/

using ..PyObjects

include("opcode.jl")
include("stack.jl")
include("memo.jl")
include("unpickle.jl")

const HIGHEST_PROTOCOL = 5
const DEFAULT_PROTOCOL = 4

"""
    readpkl(io_or_filename; simplify=false)

Reads a .pkl file.

By default, most values except for simple scalars are represented as objects from
`PythonIO.PyObjects` (e.g. a `dict` is returned as a `PyDict`). If `simplify` is
true, then Python objects are converted to their Julia counterparts where possible (e.g.
a `dict` is returned as a `Dict`). If `simplify` is a function, any Python object `x` is
recursively replaced by `simplify(x)`.
"""
function readpkl(io::IO; simplify=false)
    ans = unpickle(io)
    if simplify === true
        PyObjects.simplify(ans)
    elseif simplify === false
        ans
    else
        PyObjects.simplify(simplify, ans)
    end
end
readpkl(fn::AbstractString; kw...) = open(io->readpkl(io; kw...), fn)

end # module
