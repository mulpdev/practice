# --dynlibOverride:test param required on nimc
# passL required on command line or in source  
 
{. passL:"lib/libtest.a" .}

proc increment_global*(cnt: cint): cint {. importc .}

proc decrement_global*(cnt: cint): cint {. importc .}

proc get_global*(): cint {. importc .}

var my_g {. importc: "my_global" .}: cint

echo "Calling increment and decrement functions"
assert(get_global() == my_g)
discard increment_global(15.cint)
assert(get_global() == my_g)
discard decrement_global(8.cint)
assert(get_global() == my_g)

echo "Manupilating global via Nim variable"
assert(get_global() == my_g)
my_g += 42
assert(get_global() == my_g)
my_g -= 40
assert(get_global() == my_g)
my_g = 99999
assert(get_global() == my_g)
