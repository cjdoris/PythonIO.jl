struct PyNoneType <: PyObject end
struct PyIntType <: PyObject end
struct PyFloatType <: PyObject end
struct PyBoolType <: PyObject end
struct PyComplexType <: PyObject end
struct PyListType <: PyObject end
struct PyTupleType <: PyObject end
struct PyDictType <: PyObject end
struct PySetType <: PyObject end
struct PyFrozenSetType <: PyObject end
struct PyStrType <: PyObject end
struct PyBytesType <: PyObject end
struct PyByteArrayType <: PyObject end
struct PyRangeType <: PyObject end
struct PySliceType <: PyObject end
struct PyTypeType <: PyObject end
struct PyFractionType <: PyObject end
struct PyArrayType <: PyObject end
struct PyArrayReconstructor <: PyObject end
struct PyDateType <: PyObject end
struct PyTimeType <: PyObject end
struct PyDateTimeType <: PyObject end
struct PyNumPyDTypeType <: PyObject end
struct PyNumPyNDArrayType <: PyObject end

export PyNoneType, PyIntType, PyFloatType, PyBoolType, PyComplexType, PyListType,
    PyTupleType, PyDictType, PySetType, PyFrozenSetType, PyStrType, PyBytesType,
    PyByteArrayType, PyRangeType, PySliceType, PyFractionType, PyArrayType,
    PyArrayReconstructor, PyDateType, PyTimeType, PyDateTimeType, PyNumPyDTypeType,
    PyNumPyNDArrayType

const GLOBALS = Dict{Tuple{String,String},Any}(
    ("builtins", "NoneType") => PyNoneType(),
    ("builtins", "int") => PyIntType(),
    ("builtins", "float") => PyFloatType(),
    ("builtins", "bool") => PyBoolType(),
    ("builtins", "complex") => PyComplexType(),
    ("builtins", "list") => PyListType(),
    ("builtins", "tuple") => PyTupleType(),
    ("builtins", "dict") => PyDictType(),
    ("builtins", "set") => PySetType(),
    ("builtins", "frozenset") => PyFrozenSetType(),
    ("builtins", "str") => PyStrType(),
    ("builtins", "bytes") => PyBytesType(),
    ("builtins", "bytearray") => PyByteArrayType(),
    ("builtins", "range") => PyRangeType(),
    ("builtins", "slice") => PySliceType(),
    ("builtins", "type") => PyTypeType(),
    ("fractions", "Fraction") => PyFractionType(),
    ("array", "array") => PyArrayType(),
    ("array", "_array_reconstructor") => PyArrayReconstructor(),
    ("datetime", "date") => PyDateType(),
    ("datetime", "time") => PyTimeType(),
    ("datetime", "datetime") => PyDateTimeType(),
    ("numpy", "dtype") => PyNumPyDTypeType(),
    ("numpy", "ndarray") => PyNumPyNDArrayType(),
)
