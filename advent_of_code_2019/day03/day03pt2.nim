import parseutils
import strutils
const maxsize = 24000

type Coords = tuple[x: int, y:int]
type Trail = tuple[wire: int, step: int]
type TrailRef = ref Trail
type Grid = ref array[maxsize, array[maxsize, TrailRef]]

#proc `$`(grid: Grid): string =
#  for i in 0..maxsize-1:
#    echo grid[i]

proc move(vertex: var TrailRef, trail: var Trail, coords: var Coords) =
  # 0 means no wire has touched this vertex
  if vertex.wire == 0:
    vertex.wire = trail.wire
    vertex.step = trail.step
  # If the wire ids match, it's a self touch. Use first value
  elif vertex.wire == trail.wire:
    #echo " SX@   ", coords, " (vertex.wire: ",vertex.wire,", vertex.step: ",vertex.step, ") ", trail
    discard 
  # Cross detected between two different wires
  else:
    echo "  X@   ", coords, " Adding steps ", trail.step, "+", vertex.step, " = ", trail.step + vertex.step
    vertex.wire = 99 
    vertex.step = vertex.step + trail.step

proc calculate (grid: var Grid) =
  var mdistance: int  = 0 
  var tmp: int

  for y in 0..maxsize-1:
    for x in 0..maxsize-1:
      if isNil(grid[y][x]):
        continue

      if grid[y][x].wire == 99:
        tmp = grid[y][x].step
        echo "Cross at ", (x,y), " with step distance ",tmp
        if mdistance == 0 or tmp < mdistance:
          mdistance = tmp
        
  echo mdistance

proc main() =
  var grid: Grid = new Grid
  let f = open("input")
  defer: f.close()
  
  # Execute each directive in for the wires
  var wireno: int = 0
  var trail: Trail
  var distance: int
  var vertex: TrailRef
  var index: Coords = (int(maxsize/2), int(maxsize/2))
  
  for line in f.lines():
    index.x = int(maxsize/2)
    index.y = int(maxsize/2)
    wireno += 1
    trail.wire = wireno
    trail.step = 0

    for inst in line.split(","):
      discard parseInt(inst[1..^1], distance)
      
      # Walk the number of verticies in the specified direction and
      # mark each vertex with the wire id and step count
      for delta in 1..distance:
        trail.step += 1
        if inst[0] == 'R':
          index.x += 1
        elif inst[0] == 'L':
          index.x -= 1
        elif inst[0] == 'U':
          index.y -= 1
        elif inst[0] == 'D':
          index.y += 1

        if isNil(grid[index.y][index.x]):
          new(grid[index.y][index.x])

        #echo "Moving to (", index.x, ", ", index.y,")"
        vertex = grid[index.y][index.x]
      
        move(vertex, trail, index) # update that vertex

      echo "w",wireno,"-",inst," ",index

  calculate(grid)
  quit(QuitSuccess)

main()
