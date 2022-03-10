"""
    PyFuncCall(func, args)

Represents the object `func(*args)`.
"""
struct PyFuncCall
    func :: Any
    args :: Vector{Any}
end
export PyFuncCall

"""
    pyfunccall(func, args)

The result of calling `func(*args)`.

By default this is `PyFuncCall(func, args)` but you can overload it for different `func`.
"""
pyfunccall(func, args) = PyFuncCall(func, args)
export pyfunccall

function pyfunccall(func::PySliceType, args)
    if length(args)==3
        PySlice(args[1], args[2], args[3])
    else
        PyFuncCall(func, args)
    end
end

function pyfunccall(func::PyRangeType, args)
    if length(args)==3
        PyRange(args[1], args[2], args[3])
    else
        PyFuncCall(func, args)
    end
end

function pyfunccall(func::PyComplexType, args)
    if length(args)==2
        x, y = args
        if x isa Real && y isa Real
            Complex(x, y)
        else
            PyFuncCall(func, args)
        end
    else
        PyFuncCall(func, args)
    end
end

function pyfunccall(func::PyByteArrayType, args)
    if length(args) == 0
        return PyByteArray()
    elseif length(args) == 1
        x = args[1]
        if x isa PyBytes
            PyByteArray(x.values)
        elseif x isa AbstractVector{UInt8}
            PyByteArray(x)
        else
            PyFuncCall(func, args)
        end
    else
        PyFuncCall(func, args)
    end
end

function pyfunccall(func::PyArrayReconstructor, args)
    if length(args) == 4
        # TODO: not sure what n is?
        # TODO: do i need to worry about endianness?
        cls, t, n, data = args
        if cls === PyArrayType() && t isa String && data isa PyBytes
            if t == "b"
                T = Cchar
            elseif t == "B"
                T = Cuchar
            elseif t == "u"
                T = Cwchar_t
            elseif t == "h"
                T = Cshort
            elseif t == "H"
                T = Cushort
            elseif t == "i"
                T = Cint
            elseif t == "I"
                T = Cuint
            elseif t == "l"
                T = Clong
            elseif t == "L"
                T = Clong
            elseif t == "q"
                T = Clonglong
            elseif t == "Q"
                T = Culonglong
            elseif t == "f"
                T = Cfloat
            elseif t == "d"
                T = Cdouble
            else
                PyFuncCall(func, args)
            end
            arr = reinterpret(T, data.values)
            return PyArray{T}(arr)
        else
            PyFuncCall(func, args)
        end
    else
        PyFuncCall(func, args)
    end
end
