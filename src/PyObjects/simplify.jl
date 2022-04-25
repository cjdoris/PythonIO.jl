_map(s, x) = x
_map(s, x::PyComplex) = PyComplex(s(x.real), s(x.imag))
_map(s, x::PyRange) = PyRange(s(x.start), s(x.stop), s(x.step))
_map(s, x::PySlice) = PySlice(s(x.start), s(x.stop), s(x.step))
_map(s, x::PyList) = PyList(s(v) for v in x.values)
_map(s, x::PyTuple) = PyTuple(s(v) for v in x.values)
_map(s, x::PyDict) = PyDict(s(k) => s(v) for (k, v) in x.items)
_map(s, x::PySet) = PySet(s(v) for v in x.values)
_map(s, x::PyFrozenSet) = PyFrozenSet(s(v) for v in x.values)
_map(s, x::PyFuncCall) = PyFuncCall(s(x.func), [s(x) for x in x.args], s(x.state))
_map(s, x::PyNewObj) = PyNewObj(s(x.cls), [s(x) for x in x.args], [s(k) => s(v) for (k, v) in x.kwargs], s(x.state))

walk(f, x; cache::IdDict=IdDict()) = get!(cache, x) do
    z = _map(x) do y
        walk(f, y; cache)
    end
    f(z)
end

simplify_walker(x) = x
simplify_walker(x::PyGlobal) = get(GLOBALS, (x.mod, x.attr), x)
simplify_walker(x::PyFuncCall) =
    try
        _funccall(x.func, x.args, x.state)
    catch err
        @debug "_funccall" x err
        x
    end

simplify(x; cache=IdDict()) = walk(simplify_walker, x; cache)

native_walker(x) = x
native_walker(x::PyComplex) = Complex(x.real, x.imag)
native_walker(x::PyRange) = StepRange(x.start, x.step, x.stop)
native_walker(x::PyList) = [x for x in x.values]
native_walker(x::PyTuple) = Tuple(x.values)
native_walker(x::PyDict) = Dict(k=>v for (k,v) in x.items)
native_walker(x::PySet) = Set(x for x in x.values)
native_walker(x::PyFrozenSet) = Set(x for x in x.values)
native_walker(x::PyBytes) = codeunits(String(x.values))
native_walker(x::PyByteArray) = copy(x.values)
native_walker(x::PyArray) = copy(x.values)

walk(f::Bool, x; cache::IdDict=IdDict()) = f ? walk(native_walker, x; cache) : x

map_walk(f, x; cache=IdDict()) = map(x->walk(f, x; cache), x)
map_simplify(x; cache=IdDict()) = map(x->simplify(x; cache), x)
