let textSize = 24
let nodeRadius = 25
let boxSize = 2 * int_of_float(Math.sqrt(2.0) *. Int.toFloat(nodeRadius))
let strokeWeight = 2

let setup = () => {
  let canvasHeight = 1000 // boxSize * 10
  let canvasWidth = 1000 // boxSize * 10
  P5.createCanvas(canvasWidth, canvasHeight)->P5.parent("canvas-hole")
  P5.textSize(20)
  P5.noLoop()
}

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

let drawBox = (x: int, y: int) => {
  P5.strokeWeight(strokeWeight)
  P5.fillColor(ColorCode.light_blue)
  P5.rect(x-boxSize/2, y-boxSize/2, boxSize, boxSize)
}

let drawStack = (arr: array<string>) => {
  let sx = 100
  let sy = 100
  let padding = 15

  arr->Array.forEachWithIndex((text, i) => {
    let x = sx + i * (boxSize + padding)
    let y = sy + boxSize / 2
    drawBox(x, y)
    drawNode(x, y, text)
  })

  let n = arr->Array.length
  let sx1 = sx - boxSize/2 - padding
  let sx2 = sx1 + n * (boxSize + padding) + padding
  let sy1 = sy - padding
  let sy2 = sy + boxSize + padding
  P5.strokeWeight(2*strokeWeight)
  P5.line(sx1, sy1, sx2, sy1)
  P5.line(sx1, sy2, sx2, sy2)
  P5.line(sx2, sy1, sx2, sy2)
}

let draw = () => {
  P5.backgroundGray(200)
  drawStack(["A", "B", "C", "D"])
}

Window.window["setup"] = setup
Window.window["draw"] = draw
