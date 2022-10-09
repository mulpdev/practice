# dynlib reference to lib is from point of compilation. In this case the nimble script

proc increment_global(cnt: cint): cint {. cdecl, importc, dynlib: "lib/libtest.so" .}

proc decrement_global(cnt: cint): cint {. cdecl, importc, dynlib: "lib/libtest.so" .}

proc get_global(): cint {. cdecl, importc, dynlib: "lib/libtest.so" .}

var my_g {. importc: "my_global", dynlib: "lib/libtest.so" .}: cint

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
