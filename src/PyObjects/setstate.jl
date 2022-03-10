"""
    pysetstate!(obj, arg)

Equivalent to calling `obj.__setstate__(arg)` or `obj.__dict__.update(arg)`.
"""
pysetstate!(obj, arg) = error("not implemented")
pysetstate!(obj::PyNewObj, arg) = (obj.state = arg; obj)
export pysetstate!
