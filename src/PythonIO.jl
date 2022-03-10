module PythonIO

include("PyObjects/PyObjects.jl")
include("Numpy/Numpy.jl")
include("Pickle/Pickle.jl")

import .Numpy: readnpy, writenpy, readnpz, writenpz
import .Pickle: readpkl

export readnpy, writenpy, readnpz, writenpz, readpkl

end
