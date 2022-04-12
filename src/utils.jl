module Utils

function pickle(io::IO, x::String; imports=[])
    code = """
    import $(join(["pickle"; "sys"; imports], ", "))
    x = $x
    pickle.dump(x, sys.stdout.buffer)
    """
    run(pipeline(`python -c $code`, io))
end

end
