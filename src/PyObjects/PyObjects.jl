"""
    module PyObjects

Julia representations of Python objects.
"""
module PyObjects

abstract type PyObject end
export PyObject

include("collections.jl")
include("globals.jl")
include("funccall.jl")
include("newobj.jl")
include("setstate.jl")
include("simplify.jl")

end
