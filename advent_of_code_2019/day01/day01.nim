import math
import parseutils

proc main() =
  let f = open("input")
  defer: f.close()

  var mass = 0
  var fuel = 0
  var sum = 0

  for line in f.lines():
    discard line.parseInt(mass)
    fuel = floorDiv(mass, 3) - 2
    sum += fuel
    echo "Fuel for mass ", mass, " is ", fuel

    # Second half
    while fuel > 0:
      fuel = floorDiv(fuel, 3) - 2
      if fuel <= 0:
        break
      else:
        echo "\tFuel 2 is ", fuel
        sum += fuel
  
  echo "Sum is ",sum

main()
