type t

@send external parent: (t, string) => unit = "parent"
@val external backgroundGray: int => unit = "background"
@val external beginShape: unit => unit = "beginShape"
@val external center: int = "CENTER"
@val external left: int = "LEFT"
@val external bottom: int = "BOTTOM"
@val external close: int = "CLOSE"
@val external createCanvas: (int, int) => t = "createCanvas"
@val external ellipse: (int, int, int, int) => unit = "ellipse"
@val external endShape: int => unit = "endShape"
@val external endShapeNull: unit => unit = "endShape"
@val external line: (int, int, int, int) => unit = "line"
@val external noLoop: unit => unit = "noLoop"
@val external rect: (int, int, int, int) => unit = "rect"
@val external redraw: unit => unit = "redraw"
@val external textAlign: (int, int) => unit = "textAlign"
@val external textSize: int => unit = "textSize"
@val external text: (string, int, int) => unit = "text"
@val external strokeWeight: int => unit = "strokeWeight"
@val external triangle: (int, int, int, int, int, int) => unit = "triangle"
@val external vertex: (int, int) => unit = "vertex"

@val external rawFill: ((int, int, int)) => unit = "rawFill"
%%raw(`
function rawFill(color_code) {
  fill.apply(null, color_code);
}
`)

let fillColor = rawFill
