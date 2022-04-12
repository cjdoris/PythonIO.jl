"""
    module PyObjects

Julia representations of Python objects.
"""
module PyObjects

abstract type PyObject end
export PyObject

include("collections.jl")
include("abstract.jl")
include("simplify.jl")
include("globals.jl")
include("funccall.jl")

end
