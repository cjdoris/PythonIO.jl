@enum OpCode::UInt8 begin
    # ============================
    # PROTOCOL 0/1

    # push special markobeject on stack
    OP_MARK = 0x28

    # every pickle ends with STOP
    OP_STOP = 0x2E

    # discard topmost stack item
    OP_POP = 0x30

    # discard stack top through topmost markobject
    OP_POP_MARK = 0x31

    # duplicate top stack item
    OP_DUP = 0x32

    # push float object; decimal string argument
    OP_FLOAT = 0x36

    # push integer or bool; decimal string argument
    OP_INT = 0x49

    # push four-byte signed int
    OP_BININT = 0x4A

    # push 1-byte unsigned int
    OP_BININT1 = 0x4B

    # push long; decimal string argument
    OP_LONG = 0x4C

    # push 2-byte unsigned int
    OP_BININT2 = 0x4D

    # push None
    OP_NONE = 0x4E

    # push persistent object; id is taken from string arg
    OP_PERSID = 0x50

    # push persistent object; id is taken from stack
    OP_BINPERSID = 0x51

    # apply callable to argtuple, both on stack
    OP_REDUCE = 0x52

    # push string; NL-terminated string argument
    OP_STRING = 0x53

    # push string; counted binary string argument
    OP_BINSTRING = 0x54

    # push string; counted binary string argument 256 bytes
    OP_SHORT_BINSTRING = 0x55

    # push Unicode string; raw-unicode-escaped argument
    OP_UNICODE = 0x56

    # push Unicode string; counted UTF-8 string argument
    OP_BINUNICODE = 0x58

    # append stack top to list below it
    OP_APPEND = 0x61

    # call __setstate__ or __dict__.update()
    OP_BUILD = 0x62

    # push self.find_class(modname, name); 2 string args
    OP_GLOBAL = 0x63

    # build a dict from stack items
    OP_DICT = 0x64

    # push empty dict
    OP_EMPTY_DICT = 0x7d

    # extend list on stack by topmost stack slice
    OP_APPENDS = 0x65

    # push item from memo on stack; index is string arg
    OP_GET = 0x67

    # push item from memo on stack; index is 1-byte arg
    OP_BINGET = 0x68

    # build & push class instance
    OP_INST = 0x69

    # push item from memo on stack; index is 4-byte arg
    OP_LONG_BINGET = 0x6a

    # build list from topmost stack items
    OP_LIST = 0x6c

    # push empty list
    OP_EMPTY_LIST = 0x5d

    # build & push class instance
    OP_OBJ = 0x6f

    # store stack top in memo; index is string arg
    OP_PUT = 0x70

    # store stack top in memo; index is 1-byte arg
    OP_BINPUT = 0x71

    # store stack top in memo; index is 4-byte arg
    OP_LONG_BINPUT = 0x72

    # add key+value pair to dict
    OP_SETITEM = 0x73

    # build tuple from topmost stack items
    OP_TUPLE = 0x74

    # push empty tuple
    OP_EMPTY_TUPLE = 0x29

    # modify dict by adding topmost key+value pairs
    OP_SETITEMS = 0x75

    # push float; arg is 8-byte float encoding
    OP_BINFLOAT = 0x47


    # ============================
    # PROTOCOL 2

    # identify pickle protocol
    OP_PROTO = 0x80

    # build object by applying cls.__new__ to argtuple
    OP_NEWOBJ = 0x81

    # push object from extension registry; 1-byte index
    OP_EXT1 = 0x82

    # ditto, but 2-byte index
    OP_EXT2 = 0x83

    # ditto, but 4-byte index
    OP_EXT4 = 0x84

    # build 1-tuple from stack top
    OP_TUPLE1 = 0x85

    # build 2-tuple from two topmost stack items
    OP_TUPLE2 = 0x86

    # build 3-tuple from three topmost stack items
    OP_TUPLE3 = 0x87

    # push True
    OP_NEWTRUE = 0x88

    # push False
    OP_NEWFALSE = 0x89

    # push long from < 256 bytes
    OP_LONG1 = 0x8a

    # push really big long
    OP_LONG4 = 0x8b


    # ============================
    # PROTOCOL 3

    # push bytes; counted binary string argument
    OP_BINBYTES = 0x42

    # push bytes; counted binary string argument < 256 bytes
    OP_SHORT_BINBYTES = 0x43


    # ============================
    # PROTOCOL 4

    # push short string; UTF-8 length < 256 bytes
    OP_SHORT_BINUNICODE = 0x8c

    # push very long string
    OP_BINUNICODE8 = 0x8d

    # push very long bytes string
    OP_BINBYTES8 = 0x8e

    # push empty set on the stack
    OP_EMPTY_SET = 0x8f

    # modify set by adding topmost stack items
    OP_ADDITEMS = 0x90

    # build frozenset from topmost stack items
    OP_FROZENSET = 0x91

    # like NEWOBJ but work with keyword only arguments
    OP_NEWOBJ_EX = 0x92

    # same as GLOBAL but using names on the stacks
    OP_STACK_GLOBAL = 0x93

    # store top of the stack in memo
    OP_MEMOIZE = 0x94

    # indicate the beginning of a new frame
    OP_FRAME = 0x95


    # ============================
    # PROTOCOL 5

    # push bytearray
    OP_BYTEARRAY8 = 0x96

    # push next out-of-band buffer
    OP_NEXT_BUFFER = 0x97

    # make top of stack readonly
    OP_READONLY_BUFFER = 0x98

end
