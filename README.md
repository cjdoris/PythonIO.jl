# PythonIO.jl

Read and write common Python data formats:
- Python literal expressions
- Pickle
- Numpy .npy and .npz files

## Install

```
pkg> add https://github.com/cjdoris/PythonIO.jl
```

## API

These most commonly used functions are exported from `PythonIO`:
- `readpyexpr(file; simplify=false)`
- `readpkl(file; simplify=false)`
- `readnpy(file)`
- `writenpy(file, array)`
- `readnpz(file, [key_or_keys])`
- `writenpz(file, dict_of_arrays)`

The `file` argument is an IO stream or filename.

Further functionality is exported from sub-modules, described below.

### PyObjects

This module contains Julia representations of Python objects. For example `PyDict`
represents a Python `dict` as a vector of key-value pairs.
