"""
    PyRange(start, stop, step)

Represents `range(start, stop, step)`.
"""
struct PyRange <: PyObject
    start :: Any
    stop :: Any
    step :: Any
end
export PyRange

"""
    PySlice(start, stop, step)

Represents `slice(start, stop, step)`.
"""
struct PySlice <: PyObject
    start :: Any
    stop :: Any
    step :: Any
end
export PySlice

"""
    PyList(values)

Represents a `list`.
"""
struct PyList <: PyObject
    values :: Vector{Any}
    PyList(xs) = new(Any[x for x in xs])
    PyList() = new(Any[])
end
export PyList

"""
    PyTuple(values)

Represents a `tuple`.
"""
struct PyTuple <: PyObject
    values :: Vector{Any}
    PyList(xs) = new(Any[x for x in xs])
    PyList() = new(Any[])
end
export PyTuple

"""
    PyDict(items)

Represents a `dict`.
"""
struct PyDict <: PyObject
    items :: Vector{Pair{Any,Any}}
    PyDict(xs) = new(Pair{Any,Any}[x for x in xs])
    PyDict() = new(Pair{Any,Any}[])
end
export PyDict

"""
    PySet(values)

Represents a `set`.
"""
struct PySet <: PyObject
    values :: Vector{Any}
    PySet(xs) = new(Any[x for x in xs])
    PySet() = new(Any[])
end
export PySet

"""
    PyFrozenSet(values)

Represents a `frozenset`.
"""
struct PyFrozenSet <: PyObject
    values :: Vector{Any}
    PyFrozenSet(xs) = new(Any[x for x in xs])
    PyFrozenSet() = new(Any[])
end
export PyFrozenSet

"""
    PyBytes(values)

Represents a `bytes`.
"""
struct PyBytes <: PyObject
    values :: Vector{UInt8}
    PyBytes(xs) = new(UInt8[x for x in xs])
    PyBytes() = new(UInt8[])
end
export PyBytes

"""
    PyByteArray(values)

Represents a `bytearray`.
"""
struct PyByteArray <: PyObject
    values :: Vector{UInt8}
    PyByteArray(xs) = new(UInt8[x for x in xs])
    PyByteArray() = new(UInt8[])
end
export PyByteArray

"""
    PyArray{T}(values)

Represents an `array.array`.
"""
struct PyArray{T} <: PyObject
    values :: Vector{T}
    PyArray{T}(xs) where {T} = new{T}(T[x for x in xs])
    PyArray{T}() where {T} = new{T}(T[])
end
export PyArray
