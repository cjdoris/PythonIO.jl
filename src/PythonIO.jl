module PythonIO

include("py.jl")
include("npy.jl")
include("npz.jl")
include("pkl.jl")

import .Npy: readnpy, writenpy
import .Npz: readnpz, writenpz

export readnpy, writenpy, readnpz, writenpz

end # module
