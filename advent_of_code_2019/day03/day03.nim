import parseutils
import strutils
const maxsize = 78000

type Coords = tuple[x: int, y:int]
type Grid = ref array[maxsize, array[maxsize, uint8]]

proc `$`(grid: Grid): string =
  for i in 0..maxsize-1:
    echo grid[i]

proc move(grid: var Grid, index: var Coords, step: string, marker: uint8): Coords =
  var distance: int
  discard parseInt(step[1..^1], distance)
 
  let x = index.x
  let y = index.y

  if step[0] == 'R':
    for delta in 1..distance:
      if grid[y][x+delta] != 0'u8 and grid[y][x+delta] != marker:
        grid[y][x+delta] = 9
      else:
        grid[y][x+delta] = marker
    index.x += distance
  
  elif step[0] == 'L':
    for delta in 1..distance:
      if grid[y][x-delta] != 0'u8 and grid[y][x-delta] != marker:
        grid[y][x-delta] = 9 
      else:
        grid[y][x+delta] = marker
    index.x -= distance
  elif step[0] == 'U':
    for delta in 1..distance:
      if grid[y-delta][x]  != 0.uint8 and grid[y-delta][x] != marker:
        grid[y-delta][x] = 9 
      else:
        grid[y-delta][x] = marker
    index.y -= distance
  elif step[0] == 'D':
    for delta in 1..distance:
      if grid[y+delta][x] != 0.uint8 and grid[y+delta][x] != marker:
        grid[y+delta][x] = 9 
      else:
        grid[y+delta][x] = marker
    index.y += distance
  else:
    echo "Not a direction: ", step[0]

  return index

proc getDistance(p: Coords, q: Coords): int =
  return abs(p.x - q.x) + abs(p.y - q.y)
  

proc manhatten (grid: var Grid, start: Coords): void =
  var mdistance: int  = -1
  var tmp: int

  for x in 0..maxsize-1:
    for y in 0..maxsize-1:
      if grid[x][y] == 9'u8:
        tmp = getDistance(start, (x,y))
        echo "Cross at ", (x,y), " with MD from ",start, " ",tmp
        if mdistance < 0 or tmp < mdistance:
          mdistance = tmp
        
  echo mdistance
  

proc main() =
  var grid: Grid = new Grid
  for x in 0..maxsize-1:
    for y in 0..maxsize-1:
      grid[x][y] = 0.uint8 

  var index: Coords = (int(maxsize/2), int(maxsize/2))
  grid[index.y][index.x] = 0

  let f = open("input")
  defer: f.close()
  
  var marker: uint8 = 0
  for line in f.lines():
    marker += 1
    for inst in line.split(","):
      index = move(grid, index, inst, marker)
      echo inst," ",index
    index.x = int(maxsize/2)
    index.y = int(maxsize/2)

  #echo grid
  #[
  echo "r, l, u, d"
  echo r
  echo l
  echo u
  echo d
  ]#
  manhatten(grid, (int(maxsize/2), int(maxsize/2)))


main()
