import strutils
import parseutils
import system

proc main() =
  let intcodeStr = readFile("input")
  #let intcodeStr = "1,1,1,4,99,5,6,0,99"

  var intcodeStrSeq = intcodeStr.split(",")
  var intcode: seq[int] = @[] # intcode2 = newSeq[int](10) # pre-alloc to 10, not max

  # Convert from seq of strings to seq of ints
  for x in 0 .. len(intcodeStrSeq)-1:
    var tmp: int
    discard parseInt(intcodeStrSeq[x],tmp)
    intcode.add(tmp)

  # restore to 1202 alarm state
  intcode[1] = 12
  intcode[2] = 2

  var index = 0
  var opcode: int
  var pos1: int
  var pos2: int
  var pos3: int
 
  while index < len(intcode)-1:
    echo index
  
    opcode = intcode[index]

    if opcode == 99:
      echo "intcode[0] = ",intcode[0]
      echo "DONE!"

    elif opcode == 1 or opcode == 2:
      pos1 = intcode[index+1]
      pos2 = intcode[index+2]
      pos3 = intcode[index+3]

      if opcode == 1:
        intcode[pos3] = intcode[pos1] + intcode[pos2]
      
      if opcode == 2:
        intcode[pos3] = intcode[pos1] * intcode[pos2]

    else:
      echo "opcode invalid: ", opcode

    index += 4
  
  echo intcode

main()
