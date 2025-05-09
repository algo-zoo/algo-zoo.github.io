let strokeWeight = 2
let textSize = 24
let nodeRadius = 25

let drawNode = (x: int, y: int, label: string) => {
  let nodeSize = nodeRadius * 2
  P5.strokeWeight(strokeWeight)
  P5.fillColor(ColorCode.white)
  P5.ellipse(x, y, nodeSize, nodeSize)
  P5.textAlign(P5.center, P5.center)
  P5.textSize(textSize)
  P5.fillColor(ColorCode.black)
  P5.text(label, x, y)
}

let epsilon = 0.00001

// let calc_dist = (x1: float, y1: float, x2: float, y2: float): float =>
//   Math.sqrt((x1 -. x2) *. (x1 -. x2) +. (y1 -. y2) *. (y1 -. y2))

let calc_dist = %raw(`
  function(x1, y1, x2, y2) {
    return Math.sqrt((x1-x2)**2 + (y1-y2)**2);
  }
`)

// let calc_edge_point = (
//   x1: int, 
//   y1: int, 
//   x2: int, 
//   y2: int, 
//   r: int
// ): (float, float) => {
//   let fx1 = float_of_int(x1)
//   let fy1 = float_of_int(y1)
//   let fx2 = float_of_int(x2)
//   let fy2 = float_of_int(y2)
//   let fr = float_of_int(r)
//   let newX1 = if x1 == x2 { fx1 +. epsilon } else { fx1 }
//   let d = (fy2 -. fy1) /. (fx2 -. newX1)
//   let f = fr /. Math.sqrt(1. +. d *. d)
//   let qx = newX1 +. f
//   let qy = fy1 +. d *. f
//   let rx = newX1 -. f
//   let ry = fy1 -. d *. f
//   let mx = (newX1 +. fx2) /. 2.
//   let my = (fy1 +. fy2) /. 2.
//   if calc_dist(qx, qy, mx, my) < calc_dist(rx, ry, mx, my) {
//     (qx, qy)
//   } else {
//     (rx, ry)
//   }
// }

let calc_edge_point = %raw(`
  function(x1, y1, x2, y2, px, py, r) {
    if (x1 == x2)
      x1 += epsilon;
    const d = (y2 - y1) / (x2 - x1);
    const f = r / Math.sqrt(1 + d*d);
    const [qx, qy] = [x1 + f, y1 + d * f];
    const [rx, ry] = [x1 - f, y1 - d * f];
    const [mx, my] = [(x1+x2)/2, (y1+y2)/2];
    if (calc_dist(qx, qy, mx, my) < calc_dist(rx, ry, mx, my)) {
      return [qx, qy];
    } else {
      return [rx, ry];
    }
  }
`)

// let rotation = (cx: float, cy: float, x: float, y: float, theta: float): (float, float) => {
//   let tx = (x -. cx) *. Math.cos(theta) -. (y -. cy) *. Math.sin(theta) +. cx
//   let ty = (x -. cx) *. Math.sin(theta) +. (y -. cy) *. Math.cos(theta) +. cy
//   (tx, ty)
// }

let rotation = %raw(`
  function(cx, cy, x, y, theta) {
    const tx = (x - cx) * Math.cos(theta) - (y - cy) * Math.sin(theta) + cx;
    const ty = (x - cx) * Math.sin(theta) + (y - cy) * Math.cos(theta) + cy;
    return [tx, ty];
  }
`)
 
// let draw_arrow = (x1: int, y1: int, x2: int, y2: int): unit => {
//   let fx2 = float_of_int(x2)
//   let fy2 = float_of_int(y2)
//   P5.line(x1, y1, x2, y2)
//   let (ax, ay) = calc_edge_point(x2, y2, x1, y1, 10)
//   let (bx, by) = rotation(fx2, fy2, ax, ay, Math.Constants.pi /. 8.)
//   let (cx, cy) = rotation(fx2, fy2, ax, ay, -.(Math.Constants.pi) /. 8.)
//   P5.triangle(
//     x2,
//     y2,
//     int_of_float(bx),
//     int_of_float(by),
//     int_of_float(cx),
//     int_of_float(cy)
//   )
// }
