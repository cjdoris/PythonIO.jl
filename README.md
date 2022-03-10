# PythonIO.jl

Read a write common Python data formats.

Supports:
- Python literals (to do)
- Numpy .npy and .npz files
- Pickle (to do)

## Install

```
pkg> add https://github.com/cjdoris/PythonIO.jl
```

## Main API

- `readnpy(file)`
- `writenpy(file, array)`
- `readnpz(file, [key_or_keys])`
- `writenpz(file, dict_of_arrays)`
