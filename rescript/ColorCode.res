let grayScale = (v: int): (int, int, int) => {
  Console.assert_(0 <= v && v <= 255, "Scale error")
  (v, v, v)
}

let hsv = (h: int, s: int, v: int): (int, int, int) => {
  Console.assert_(0 <= h && h <= 360, "Scale error")
  Console.assert_(0 <= s && s <= 100, "Scale error")
  Console.assert_(0 <= v && v <= 100, "Scale error")

  let normalize = x => int_of_float(Math.round(x *. 255.0))
  let hf = float_of_int(h)
  let sf = float_of_int(s) /. 100.0
  let vf = float_of_int(v) /. 100.0

  if (s == 0) { // Gray scale
    let v = normalize(vf)
    (v, v, v)
  } else {
    let nh = hf /. 60.0
    let i = int_of_float(Math.floor(nh))
    let f = nh -. float_of_int(i)

    let p = vf *. (1.0 -. sf)
    let q = vf *. (1.0 -. sf *. f)
    let t = vf *. (1.0 -. sf *. (1.0 -. f))
    let (rf, gf, bf) = switch i {
      | 0 => (vf, t, p)
      | 1 => (q, vf, p)
      | 2 => (p, vf, t)
      | 3 => (p, q, vf)
      | 4 => (t, p, vf)
      | _ => (vf, p, q)
    }

    let r = normalize(rf)
    let g = normalize(gf)
    let b = normalize(bf)
    (r, g, b)
  }
}

let black       = grayScale(0)
let dark        = grayScale(30)
let gray        = grayScale(50)
let light_gray  = grayScale(80)
let white       = grayScale(255)

let red         = hsv(18, 80, 100)
let yellow      = hsv(57, 80, 100)
let blue        = hsv(200, 80, 100)
let light_blue  = hsv(200, 20, 100)
let orange      = hsv(40, 80, 100)
