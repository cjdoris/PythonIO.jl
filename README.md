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

## API

These most commonly used functions are exported from `PythonIO`:
- `readnpy(file)`
- `writenpy(file, array)`
- `readnpz(file, [key_or_keys])`
- `writenpz(file, dict_of_arrays)`

### Numpy

For finer-grained reading and writing, `PythonIO.Numpy` additionally exports:
- `NpyDescr`
- `NpyHeader`
- `readnpyheader(io)`
- `readnpydata(io, header)`
- `NpzReader(io_or_filename)`
- `readnpy(npzreader, key)`
- `readnpyheader(npzreader, key)`
- `NpzWriter(io_or_filename)`
- `writenpy(npzwriter, key, array)`
