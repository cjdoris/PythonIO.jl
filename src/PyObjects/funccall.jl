function _funccall(func::PySliceType, args, ::Nothing)
    a, b, c = args
    PySlice(a, b, c)
end

function _funccall(func::PyRangeType, args, ::Nothing)
    a, b, c = args
    PyRange(a, b, c)
end

function _funccall(func::PyComplexType, args, ::Nothing)
    a, b = args
    PyComplex(a, b)
end

function _funccall(func::PyByteArrayType, args, ::Nothing)
    if length(args) == 0
        PyByteArray()
    elseif length(args) == 1
        a = args[1]::PyBytes
        PyByteArray(a.values)
    else
        error()
    end
end

function _funccall(func::PyArrayReconstructor, args, ::Nothing)
    # TODO: not sure what n is?
    # TODO: do i need to worry about endianness?
    cls, t, n, data = args
    (cls === PyArrayType() && t isa String && data isa PyBytes) || error()
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
        error()
    end
    arr = reinterpret(T, data.values)
    PyArray{T}(arr)
end
