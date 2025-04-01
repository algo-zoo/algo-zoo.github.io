type fpoint = (float, float)
type point = (int, int)

let cross = (pt1: fpoint, pt2: fpoint) => {
  let (x1, y1) = pt1
  let (x2, y2) = pt2
  x1 *. y2 -. y1 *. x2
}

let ccw = (p: fpoint, q: fpoint, r: fpoint) => {
  let (px, py) = p
  let (qx, qy) = q
  let (rx, ry) = r

  let pq = (qx -. px, qy -. py)
  let qr = (rx -. qx, ry -. qy)
  cross(pq, qr) > 0.0
}

let hull = (pts: array<point>): array<point> => {
  let fpts: array<fpoint> = pts->Array.map(v => {
    let (p, q) = v
    (float_of_int(p), float_of_int(q))
  })->Array.toSorted((pt1, pt2) => {
    let (x1, y1) = pt1
    let (x2, y2) = pt2
    // Points closer to the upper left point (0, 0)
    // will appear earlier in the resulting array
    (x1 +. y1) -. (x2 +. y2)
  }) 
  let n = fpts->Array.length

  let calcNext = (currentIdx: int): int => {
    let rec loop = (i: int, candidateIdx: int): int => {
      if i >= n {
        candidateIdx
      } else {
        let next = if ccw(
          fpts->Array.getUnsafe(currentIdx),
          fpts->Array.getUnsafe(i),
          fpts->Array.getUnsafe(candidateIdx)
        ) {
          i
        } else {
          candidateIdx
        }
        loop(i+1, next)
      }
    }
    loop(0, mod(currentIdx+1, n))
  }

  if n <= 2 {
    []
  } else {
    let hull: array<point> = []
    let rec loop = (currentIdx: int): unit => {
      let (x, y) = fpts->Array.getUnsafe(currentIdx)
      hull->Array.push((int_of_float(x), int_of_float(y)))
      let nextIdx = calcNext(currentIdx)
      if nextIdx == 0 {
        ()
      } else {
        loop(nextIdx)
      }
    }
    loop(0)
    hull
  }
}
