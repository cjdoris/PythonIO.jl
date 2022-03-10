# PythonIO.jl

Read a write common Python data formats.

Supports:
- Python literals (to do)
- Pickle
- Numpy .npy and .npz files

## Install

```
pkg> add https://github.com/cjdoris/PythonIO.jl
```

## API

These most commonly used functions are exported from `PythonIO`:
- `readpkl(file)`
- `readnpy(file)`
- `writenpy(file, array)`
- `readnpz(file, [key_or_keys])`
- `writenpz(file, dict_of_arrays)`
