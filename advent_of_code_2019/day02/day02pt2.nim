import strutils
import parseutils
import system

proc computer(program: seq[int], noun: int, verb: int): int =

  # restore to 1202 alarm state
  var memory = program
  memory[1] = noun
  memory[2] = verb

  var inst_ptr = 0
  var opcode: int
  var param1: int
  var param2: int
  var param3: int
 
  while inst_ptr < len(memory)-1:
    opcode = memory[inst_ptr]

    if opcode == 99:
      return memory[0]

    elif opcode == 1 or opcode == 2:
      param1 = memory[inst_ptr+1]
      param2 = memory[inst_ptr+2]
      param3 = memory[inst_ptr+3]

      if opcode == 1:
        memory[param3] = memory[param1] + memory[param2]
      
      if opcode == 2:
        memory[param3] = memory[param1] * memory[param2]

    else:
      echo "opcode invalid: ", opcode
      return -1

    inst_ptr += 4
  
  return -2

let intcodeStr = readFile("input")
var intcodeStrSeq = intcodeStr.split(",")
var intcode: seq[int] = @[]

# Convert from seq of strings to seq of ints
for x in 0 .. len(intcodeStrSeq)-1:
  var tmp: int
  discard parseInt(intcodeStrSeq[x],tmp)
  intcode.add(tmp)

for x in 0 .. 100:
  for y in 0 .. 100:
    var ret = computer(intcode,x, y) 
    if ret == 19690720:
      echo x,", ",y," = ",ret
      echo "DONE"
      echo 100*x + y
      quit(QuitSuccess) 
echo "Not found :("
