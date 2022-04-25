int_or_bigint(x) = (y=mod(x,Int); x==y ? convert(Int,x) : convert(BigInt,y))

mutable struct UnpickleState
    stack :: Stack
    proto :: Int
    pos :: Int
    memo :: Memo
end
UnpickleState() = UnpickleState(Stack(), HIGHEST_PROTOCOL, 1, Memo())

function read_opcode(io::IO, state::UnpickleState)
    ans = read(io, OpCode)
    state.pos += sizeof(OpCode)
    ans
end

function read_prim_l(io::IO, state::UnpickleState, ::Type{T}) where {T}
    ans = ltoh(read(io, T))
    state.pos += sizeof(T)
    ans
end

function read_prim_b(io::IO, state::UnpickleState, ::Type{T}) where {T}
    ans = ntoh(read(io, T))
    state.pos += sizeof(T)
    ans
end

read_u1(io::IO, state::UnpickleState) = read_prim_l(io, state, UInt8)
read_u2(io::IO, state::UnpickleState) = read_prim_l(io, state, UInt16)
read_u4(io::IO, state::UnpickleState) = read_prim_l(io, state, UInt32)
read_u8(io::IO, state::UnpickleState) = read_prim_l(io, state, UInt64)
read_s4(io::IO, state::UnpickleState) = read_prim_l(io, state, Int32)
read_f8(io::IO, state::UnpickleState) = read_prim_b(io, state, Float64)

function read_bytes(io::IO, state::UnpickleState, sz::Integer)
    ans = read(io, sz)
    state.pos += length(ans)
    length(ans) == sz || error("unexpected end of file")
    ans
end

function read_line(io::IO, state::UnpickleState)
    ans = readuntil(io, '\n', keep=false)
    state.pos += sizeof(ans) + 1
    ans
end

function read_stringnl_noescape(io::IO, state::UnpickleState)
    read_line(io, state)
end

function read_decimalnl_short(io::IO, state::UnpickleState)
    line = read_line(io, state)
    if line == "00"
        return false
    elseif line == "01"
        return true
    end
    return int_or_bigint(parse(BigInt, line))
end

function read_floatnl(io::IO, state::UnpickleState)
    line = read_line(io, state)
    return parse(Float64, line)
end

function unpickle(io::IO)
    state = UnpickleState()
    # optional first PROTO opcode
    op = read_opcode(io, state)
    if op == OP_PROTO
        state.proto = Int(read_u1(io, state))
        stop = false
    else
        stop = doop(op, state, io)
    end
    # remaining opcodes
    while !stop
        op = read_opcode(io, state)
        stop = doop(op, state, io)
    end
    # done
    len = length(state.stack)
    if len == 1
        return pop!(state.stack)
    else
        error("unexpected STOP")
    end
end

function doop(op::OpCode, state::UnpickleState, io::IO)
    if op == OP_MARK
        mark!(state.stack)

    elseif op == OP_STOP
        return true

    elseif op == OP_POP
        pop!(state.stack)

    elseif op == OP_POP_MARK
        poptomark!(state.stack)

    elseif op == OP_DUP
        push!(state.stack, top(state.stack))

    elseif op == OP_FLOAT
        val = read_floatnl(io, state)
        push!(state.stack, val)

    elseif op == OP_INT
        val = read_decimalnl_short(io, state)
        push!(state.stack, val)

    elseif op == OP_BININT
        val = int_or_bigint(read_s4(io, state))
        push!(state.stack, val)

    elseif op == OP_BININT1
        val = int_or_bigint(read_u1(io, state))
        push!(state.stack, val)

    elseif op == OP_LONG
        error("opcode not implemented: $op")

    elseif op == OP_BININT2
        val = int_or_bigint(read_u2(io, state))
        push!(state.stack, val)

    elseif op == OP_NONE
        val = nothing
        push!(state.stack, val)

    elseif op == OP_PERSID
        error("opcode not implemented: $op")

    elseif op == OP_BINPERSID
        error("opcode not implemented: $op")

    elseif op == OP_REDUCE
        args = pop!(state.stack)::PyTuple
        func = pop!(state.stack)
        val = PyFuncCall(func, args.values)
        push!(state.stack, val)

    elseif op == OP_STRING
        error("opcode not implemented: $op")

    elseif op == OP_BINSTRING
        error("opcode not implemented: $op")

    elseif op == OP_SHORT_BINSTRING
        error("opcode not implemented: $op")

    elseif op == OP_UNICODE
        error("opcode not implemented: $op")

    elseif op == OP_BINUNICODE
        sz = read_u4(io, state)
        val = String(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_APPEND
        x = pop!(state.stack)
        list = top(state.stack)::PyList
        push!(list.values, x)

    elseif op == OP_BUILD
        arg = pop!(state.stack)
        obj = top(state.stack)
        pysetstate!(obj, arg)

    elseif op == OP_GLOBAL
        mod = read_stringnl_noescape(io, state)
        attr = read_stringnl_noescape(io, state)
        val = PyGlobal(mod, attr)
        push!(state.stack, val)

    elseif op == OP_DICT
        kvs = poptomark!(state.stack)
        iseven(length(kvs)) || error("odd number of keys and values")
        val = PyDict(Pair{Any,Any}[Pair{Any,Any}(kvs[i], kvs[i+1]) for i in 1:2:length(kvs)])
        push!(state.stack, val)

    elseif op == OP_EMPTY_DICT
        val = PyDict()
        push!(state.stack, val)

    elseif op == OP_APPENDS
        xs = poptomark!(state.stack)
        list = top(state.stack)::PyList
        append!(list.values, xs)

    elseif op == OP_GET
        error("opcode not implemented: $op")

    elseif op == OP_BINGET
        idx = read_u1(io, state)
        val = state.memo[idx]
        push!(state.stack, val)

    elseif op == OP_INST
        error("opcode not implemented: $op")

    elseif op == OP_LONG_BINGET
        idx = read_u4(io, state)
        val = state.memo[idx]
        push!(state.stack, val)

    elseif op == OP_LIST
        val = PyList(poptomark!(state.stack))
        push!(state.stack, val)

    elseif op == OP_EMPTY_LIST
        val = PyList()
        push!(state.stack, val)

    elseif op == OP_OBJ
        error("opcode not implemented: $op")

    elseif op == OP_PUT
        idx = read_decimalnl_short(io, state)
        state.memo[idx] = top(state.stack)

    elseif op == OP_BINPUT
        idx = read_u1(io, state)
        state.memo[idx] = top(state.stack)

    elseif op == OP_LONG_BINPUT
        idx = read_u4(io, state)
        state.memo[idx] = top(state.stack)

    elseif op == OP_SETITEM
        v = pop!(state.stack)
        k = pop!(state.stack)
        dict = top(state.stack)::PyDict
        push!(dict.items, Pair{Any,Any}(k, v))

    elseif op == OP_TUPLE
        val = PyTuple(poptomark!(state.stack))
        push!(state.stack, val)

    elseif op == OP_EMPTY_TUPLE
        val = PyTuple()
        push!(state.stack, val)

    elseif op == OP_SETITEMS
        kvs = poptomark!(state.stack)
        iseven(length(kvs)) || error("odd number of keys and values")
        dict = top(state.stack)::PyDict
        for i in 1:2:length(kvs)
            push!(dict.items, Pair{Any,Any}(kvs[i], kvs[i+1]))
        end

    elseif op == OP_BINFLOAT
        val = read_f8(io, state)
        push!(state.stack, val)

    elseif op == OP_PROTO
        error("unexpected op: $op")

    elseif op == OP_NEWOBJ
        args = pop!(state.stack)::PyTuple
        cls = pop!(state.stack)
        val = PyNewObj(cls, args.values)
        push!(state.stack, val)

    elseif op == OP_EXT1
        error("opcode not implemented: $op")

    elseif op == OP_EXT2
        error("opcode not implemented: $op")

    elseif op == OP_EXT4
        error("opcode not implemented: $op")

    elseif op == OP_TUPLE1
        x1 = pop!(state.stack)
        val = PyTuple(Any[x1])
        push!(state.stack, val)

    elseif op == OP_TUPLE2
        x2 = pop!(state.stack)
        x1 = pop!(state.stack)
        val = PyTuple(Any[x1, x2])
        push!(state.stack, val)

    elseif op == OP_TUPLE3
        x3 = pop!(state.stack)
        x2 = pop!(state.stack)
        x1 = pop!(state.stack)
        val = PyTuple(Any[x1, x2, x3])
        push!(state.stack, val)

    elseif op == OP_NEWTRUE
        val = true
        push!(state.stack, val)

    elseif op == OP_NEWFALSE
        val = false
        push!(state.stack, val)

    elseif op == OP_LONG1
        error("opcode not implemented: $op")

    elseif op == OP_LONG4
        error("opcode not implemented: $op")

    elseif op == OP_BINBYTES
        sz = read_u4(io, state)
        val = PyBytes(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_SHORT_BINBYTES
        sz = read_u1(io, state)
        val = PyBytes(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_SHORT_BINUNICODE
        sz = read_u1(io, state)
        val = String(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_BINUNICODE8
        sz = read_u8(io, state)
        val = String(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_BINBYTES8
        sz = read_u8(io, state)
        val = PyBytes(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_EMPTY_SET
        val = PySet()
        push!(state.stack, val)

    elseif op == OP_ADDITEMS
        xs = poptomark!(state.stack)
        set = top(state.stack)::PySet
        append!(set.values, xs)

    elseif op == OP_FROZENSET
        val = PyFrozenSet(poptomark!(state.stack))
        push!(state.stack, val)

    elseif op == OP_NEWOBJ_EX
        kwargs = pop!(state.stack)::PyDict
        args = pop!(state.stack)::PyTuple
        cls = pop!(state.stack)
        val = PyNewObj(cls, args.values, kwargs.items)
        push!(state.stack, val)

    elseif op == OP_STACK_GLOBAL
        attr = pop!(state.stack)::String
        mod = pop!(state.stack)::String
        val = PyGlobal(mod, attr)
        push!(state.stack, val)

    elseif op == OP_MEMOIZE
        push!(state.memo, top(state.stack))

    elseif op == OP_FRAME
        # TODO: we could reuse `frameio` to avoid some allocations
        sz = read_u8(io, state)
        pos = state.pos
        frameio = IOBuffer(read_bytes(io, state, sz))
        while !eof(frameio)
            op = read_opcode(frameio, state)
            stop = doop(op, state, frameio)
            stop && return true
        end
        state.pos = pos + sz

    elseif op == OP_BYTEARRAY8
        sz = read_u8(io, state)
        val = PyByteArray(read_bytes(io, state, sz))
        push!(state.stack, val)

    elseif op == OP_NEXT_BUFFER
        error("opcode not implemented: $op")

    elseif op == OP_READONLY_BUFFER
        error("opcode not implemented: $op")

    else
        error("opcode not implemented: $op")
    end

    return false
end
