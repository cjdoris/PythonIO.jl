"""
    simplify([f], x)

Simplify the Python objects in `x`.

Recursively walks through each nested object `y` in `x` and replaces it with `f(y)`.

If `f` is not given, the default simplifier is used, which converts objects to their native
Julia types (e.g. `dict` becomes `Dict`).
"""
simplify(f, x) = f(x)
simplify(x) = simplify(default_simplifier, x)

simplify(f, x::PyRange) = f(PyRange(simplify(f, x.start), simplify(f, x.stop), simplify(f, x.step)))
simplify(f, x::PySlice) = f(PySlice(simplify(f, x.start), simplify(f, x.stop), simplify(f, x.step)))
simplify(f, x::PyList) = f(PyList(simplify(f, v) for v in x.values))
simplify(f, x::PyTuple) = f(PyTuple(simplify(f, v) for v in x.values))
simplify(f, x::PyDict) = f(PyDict(simplify(f, k) => simplify(f, v) for (k, v) in x.items))
simplify(f, x::PySet) = f(PySet(simplify(f, v) for v in x.values))
simplify(f, x::PyFrozenSet) = f(PyFrozenSet(simplify(f, v) for v in x.values))
simplify(f, x::PyFuncCall) = f(PyFuncCall(simplify(f, x.func), [simplify(f, x) for x in x.args]))
simplify(f, x::PyNewObj) = f(PyNewObj(simplify(f, x.cls), [simplify(f, x) for x in x.args], [simplify(f, k) => simplify(f, v) for (k, v) in x.kwargs], simplify(f, x.buildarg)))

"""
    default_simplifier(x)

The default first argument to [`simplify`](@ref).
"""
default_simplifier(x) = x

default_simplifier(x::PyRange) = StepRange(x.start, x.step, x.stop)
default_simplifier(x::PyList) = [x for x in x.values]
default_simplifier(x::PyTuple) = Tuple(x.values)
default_simplifier(x::PyDict) = Dict(k=>v for (k,v) in x.items)
default_simplifier(x::PySet) = Set(x for x in x.values)
default_simplifier(x::PyFrozenSet) = Set(x for x in x.values)
default_simplifier(x::PyBytes) = codeunits(String(x.values))
default_simplifier(x::PyByteArray) = copy(x.values)
default_simplifier(x::PyArray) = copy(x.values)
