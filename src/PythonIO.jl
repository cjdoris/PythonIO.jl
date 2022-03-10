module PythonIO

include("numpy/Numpy.jl")

import .Numpy: readnpy, writenpy, readnpz, writenpz

export readnpy, writenpy, readnpz, writenpz

end
