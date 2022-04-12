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
"""
function readpkl(io::IO; simplify=false)
    ans = unpickle(io)
    if simplify !== nothing
        ans = PyObjects.simplify(ans)
        ans = PyObjects.walk(simplify, ans)
    end
    return ans
end
readpkl(fn::AbstractString; kw...) = open(io->readpkl(io; kw...), fn)

end # module
