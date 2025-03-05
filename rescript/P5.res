type t
@val external createCanvas: (int, int) => t = "createCanvas"
@send external parent: (t, string) => unit = "parent"
@val external textSize: int => unit = "textSize"
@val external noLoop: unit => unit = "noLoop"
@val external redraw: unit => unit = "redraw"
@val external backgroundGray: int => unit = "background"
@val external vertex: (int, int) => unit = "vertex"
@val external rect: (int, int, int, int) => unit = "rect"
@val external text: (string, int, int) => unit = "text"
@val external center: int = "CENTER"
@val external textAlign: (int, int) => unit = "textAlign"
@val external beginShape: unit => unit = "beginShape"
@val external endShape: int => unit = "endShape"
@val external close: int = "CLOSE"

@val external rawFill: ((int, int, int)) => unit = "rawFill"
%%raw(`
function rawFill(color_code) {
  fill.apply(null, color_code);
}
`)

let fillColor = rawFill
