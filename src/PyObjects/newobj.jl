"""
    PyNewObj(cls, args, kwargs)

Represents the results of calling `cls.__new__(*args, **kwargs)`.
"""
mutable struct PyNewObj
    cls :: Any
    args :: Vector{Any}
    kwargs :: Vector{Pair{Any,Any}}
    state :: Any
end
PyNewObj(cls, args=Any[], kwargs=Pair{Any,Any}[]) = PyNewObj(cls, args, kwargs, nothing)
export PyNewObj

"""
    pynewobj(cls, args, kwargs)

Compute the result of `cls.__new__(args, kwargs)`.

By default this is `PyNewObj(cls, args, kwargs)` but you can overload it for different
`cls`. You may also need to overload [`setstate!`](@ref).
"""
pynewobj(cls, args=Any[], kwargs=Pair{Any,Any}[]) = PyNewObj(cls, args, kwargs)
export pynewobj
