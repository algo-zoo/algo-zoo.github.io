let padding = 12
let boxSize = 2 * int_of_float(Math.sqrt(2.0) *. Int.toFloat(DrawUtil.nodeRadius))
let halfBoxSize = boxSize / 2
let quarterBoxSize = boxSize / 4
let cellSize = boxSize + 2*padding

type code = PushShow(int) | Push(int) | Pop | PopPause
type stackState = (array<int>, option<int>)

type stateType = {
  index: ref<option<int>>
}

let state:stateType = {
  index: ref(None)
}

let drawBox = (x: int, y: int, label: string): unit => {
  P5.strokeWeight(DrawUtil.strokeWeight)
  P5.strokeColor(ColorCode.black)
  P5.fillColor(ColorCode.lightBlue)
  P5.rect(x-boxSize/2, y-boxSize/2, boxSize, boxSize)
  DrawUtil.drawNode(x, y, label)
}

let drawBoxByIndex = (label: string, i: int, j: int): unit => {
  let offsetX = padding + boxSize / 2
  let offsetY = padding + boxSize / 2
  let x = offsetX + i * cellSize
  let y = offsetY + j * cellSize
  drawBox(x, y, label)
}

let drawLabel = (label: string, i: int, j: int): unit => {
  let offsetX = i * cellSize + padding
  let offsetY = j * cellSize + cellSize / 2
  P5.textSize(40)
  P5.strokeWeight(3)
  P5.strokeColor(ColorCode.black)
  P5.fillColor(ColorCode.red)
  P5.textAlign(P5.left, P5.center)
  P5.text(label, offsetX, offsetY)
}

let drawCodeLabel = (program: array<code>, i: int): unit => {
  switch program[i] {
  | Some(c) =>
    let (i, j) = (2, 0)
    switch c {
    | PushShow(n) => drawLabel("push(" ++ string_of_int(n) ++ ")", i, j)
    | Push(_) => ()
    | Pop => drawLabel("pop()", i, j)
    | PopPause => ()
    }
  | None => ()
  }
}

let drawArrow = (x: int, y: int, ~reverse: bool=false): unit => {
  let drawArrowByPoints = pts => {
    P5.strokeWeight(DrawUtil.strokeWeight)
    P5.strokeColor(ColorCode.black)
    P5.fillColor(ColorCode.white)
    P5.beginShape()
    pts->Array.forEach(pt => {
      let (u, v) = pt
      P5.vertex(u, v)
    })
    P5.endShape(P5.close)
  }
  if reverse {
    let pt1 = (x, y)
    let pt2 = (x+halfBoxSize, y-halfBoxSize)
    let pt3 = (x+halfBoxSize, y-quarterBoxSize)
    let pt4 = (x+boxSize, y-quarterBoxSize)
    let pt5 = (x+boxSize, y+quarterBoxSize)
    let pt6 = (x+halfBoxSize, y+quarterBoxSize)
    let pt7 = (x+halfBoxSize, y+halfBoxSize)
    [ pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt1 ]
    ->drawArrowByPoints
  } else {
    let pt1 = (x, y-quarterBoxSize)
    let pt2 = (x+halfBoxSize, y-quarterBoxSize)
    let pt3 = (x+halfBoxSize, y-halfBoxSize)
    let pt4 = (x+boxSize, y)
    let pt5 = (x+halfBoxSize, y+halfBoxSize)
    let pt6 = (x+halfBoxSize, y+quarterBoxSize)
    let pt7 = (x, y+quarterBoxSize)
    [ pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt1 ]
    ->drawArrowByPoints
  }
}

let drawArrowByIndex = (i: int, j: int, ~reverse: bool=false) => {
  let offsetX = padding
  let offsetY = padding + halfBoxSize
  let x = offsetX + i * cellSize
  let y = offsetY + j * cellSize
  drawArrow(x, y, ~reverse=reverse)
}

let drawStack = (arr: array<string>, maxLen: int, ~offsetI=2: int, ~offsetJ=1: int):unit => {
  arr->Array.forEachWithIndex((v, i) => {
    drawBoxByIndex(v, maxLen-i-1+offsetI, offsetJ)
  })
  let offsetX = padding + offsetI * cellSize + cellSize / 2
  let offsetY = padding + offsetJ * cellSize
  let sx1 = offsetX - cellSize / 2 - padding
  let sx2 = sx1 + maxLen * cellSize
  let sy1 = offsetY - padding
  let sy2 = offsetY + cellSize - padding
  P5.strokeWeight(2*DrawUtil.strokeWeight)
  P5.strokeColor(ColorCode.black)
  P5.line(sx1, sy1, sx2, sy1)
  P5.line(sx1, sy2, sx2, sy2)
  P5.line(sx2, sy1, sx2, sy2)
}

let loadProgram = (): array<code> => {
  let textbox = Jq.make("#program")
  let text = textbox->Jq.getValue()
  let pushRegExp = RegExp.fromString("push\\((\\d+)\\)")
  let popRegExp = RegExp.fromString("pop\\(\\)")
  let result: array<code> = []
  String.split(text, "\n")->Array.forEach(line => {
    switch RegExp.exec(pushRegExp, line) {
    | Some(m) =>
      let s = m->RegExp.Result.matches->Array.getUnsafe(0)
      let n = Int.fromString(s)->Option.getExn
      result->Array.push(PushShow(n))
      result->Array.push(Push(n))
    | None =>
      if RegExp.test(popRegExp, line) {
        result->Array.push(Pop)
        result->Array.push(PopPause)
      }
    }
  })
  result
}

let runStack = (program: array<code>, end:int): stackState => {
  let arr = []
  let rec rs = (i:int, output: option<int>) => {
    if end < i {
      (arr, output)
    } else {
      let code = program->Array.getUnsafe(i)
      let v: option<int> = switch code {
      | PushShow(n) => Some(n)
      | Push(n) => arr->Array.push(n); None
      | Pop => arr->Array.pop
      | PopPause => None
      }
      rs(i+1, v)
    }
  }
  rs(0, None)
}

let getStackState = (program: array<code>, i: int): stackState => {
  if 0 <= i && i < program->Array.length {
    runStack(program, i)
  } else {
    ([], None)
  }
}

let getMaxStackLength = (program: array<code>): int => {
  Array.fromInitializer(~length=program->Array.length, i => {
    let (stack, _) = getStackState(program, i)
    stack->Array.length
  })
  ->Array.reduce(0, (a, b) => if a < b { b } else { a })
}

let setDisable: (string, bool) => unit = %raw(`(id, flag) => $(id).prop("disabled", flag)`)

let refreshButtons = () => {
  switch state.index.contents {
  | Some(i) =>
    let n = loadProgram()->Array.length
    setDisable("#prev", i == -1)
    setDisable("#next", i+1 == n)
  | None => ()
  }
}

let isCode = (program: array<code>, i: int, op: [#push | #pop]): bool => {
  switch program[i] {
  | Some(c) =>  switch c {
    | PushShow(_) => op == #push
    | Pop => op == #pop
    | _ => false
  }
  | None => false
  }
}

let draw = () => {
  P5.backgroundGray(200)
  switch state.index.contents {
  | Some(idx) =>
    let program = loadProgram()
    let len = program->getMaxStackLength
    let (stack, output) = program->getStackState(idx)
    drawCodeLabel(program, idx)
    drawStack(stack->Array.map(string_of_int), len, ~offsetI=2, ~offsetJ=1)
    if isCode(program, idx, #push) {
      drawArrowByIndex(1, 1)
      drawBoxByIndex(string_of_int(output->Option.getExn), 0, 1)
    } else if isCode(program, idx, #pop) {
      drawArrowByIndex(1, 1, ~reverse=true)
      drawBoxByIndex(string_of_int(output->Option.getExn), 0, 1)
    }
    refreshButtons()
  | None => ()
  }
}

let setHeight: string => unit = %raw(`id => $(id).height($(id)[0].scrollHeight)`)

let initializeStack = () => {
  let id = "#program"
  let textbox = Jq.make(id)
  textbox->Jq.setValue([
    "push(4)",
    "push(2)",
    "push(9)",
    "pop()",
    "push(1)",
    "pop()",
    "push(9)",
    "push(7)",
    "push(6)",
  ]->Array.join("\n"))->ignore
  setHeight(id)
}

let setup = () => {
  P5.createCanvas(0, 0)->P5.parent("canvas-hole")
  setDisable("#prev", true)
  setDisable("#next", true)
  initializeStack()
}

let createCanvas = () => {
  let canvasHeight = cellSize * 3
  let canvasWidth = cellSize * (loadProgram()->getMaxStackLength + 4)
  P5.createCanvas(canvasWidth, canvasHeight)->P5.parent("canvas-hole")
  P5.noLoop()
}

let run = () => {
  createCanvas()
  state.index := Some(-1)
}

let prev = () => {
  switch state.index.contents {
  | Some(i) => if 0 <= i {
    state.index := Some(i - 1)
  }
  | None => ()
  }
}

let next = () => {
  switch state.index.contents {
  | Some(i) => if i < loadProgram()->Array.length-1 {
    state.index := Some(i + 1)
  }
  | None => ()
  }
}

Jq.domMake(Jq.document)->Jq.ready(() => {
  [
    ("#run", run),
    ("#prev", prev),
    ("#next", next),
  ]->Array.forEach(((id, f)) => Jq.make(id)->Jq.on("click", () => { f(); P5.redraw() }))
})

Window.window["setup"] = setup
Window.window["draw"] = draw
