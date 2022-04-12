"""
    PyGlobal(mod, attr)

Represents a global object, referenced by module and attribute
"""
struct PyGlobal <: PyObject
    mod :: String
    attr :: String
end
export PyGlobal

"""
    PyFuncCall(func, args)

Represents the object `func(*args)`.
"""
mutable struct PyFuncCall
    func :: Any
    args :: Vector{Any}
    state :: Any
end
PyFuncCall(func, args) = PyFuncCall(func, args, nothing)
export PyFuncCall

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
    pysetstate!(obj, arg)

Equivalent to calling `obj.__setstate__(arg)` or `obj.__dict__.update(arg)`.
"""
pysetstate!(obj, arg) = error("pysetstate! not implemented for obj=$obj arg=$arg")
pysetstate!(obj::PyNewObj, arg) = (obj.state = arg; obj)
pysetstate!(obj::PyFuncCall, arg) = (obj.state = arg; obj)
export pysetstate!
