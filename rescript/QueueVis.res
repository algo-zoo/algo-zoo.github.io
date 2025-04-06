let padding = 12
let boxSize = 2 * int_of_float(Math.sqrt(2.0) *. Int.toFloat(DrawUtil.nodeRadius))
let halfBoxSize = boxSize / 2
let quarterBoxSize = boxSize / 4

let cellSize = boxSize + 2*padding

type code = EnqueueShow(int) | Enqueue(int) | Dequeue | DequeuePause
type queueState = (array<int>, option<int>)

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

let drawLabel = (program: array<code>, i: int): unit => {
  let offsetX = 2 * cellSize + padding
  let offsetY = cellSize / 2
  switch program[i] {
  | Some(c) =>
    let label = switch c {
    | EnqueueShow(n) => "enqueue(" ++ string_of_int(n) ++ ")"
    | Enqueue(_) => ""
    | Dequeue => "dequeue()"
    | DequeuePause => ""
    }
    P5.textSize(40)
    P5.strokeWeight(3)
    P5.strokeColor(ColorCode.black)
    P5.fillColor(ColorCode.red)
    P5.textAlign(P5.left, P5.center)
    P5.text(label, offsetX, offsetY)
  | None => ()
  }
}

let drawArrow = (x: int, y: int): unit => {
  let pt1 = (x, y-quarterBoxSize)
  let pt2 = (x+halfBoxSize, y-quarterBoxSize)
  let pt3 = (x+halfBoxSize, y-halfBoxSize)
  let pt4 = (x+boxSize, y)
  let pt5 = (x+halfBoxSize, y+halfBoxSize)
  let pt6 = (x+halfBoxSize, y+quarterBoxSize)
  let pt7 = (x, y+quarterBoxSize)
  P5.strokeWeight(DrawUtil.strokeWeight)
  P5.strokeColor(ColorCode.black)
  P5.fillColor(ColorCode.white)
  P5.beginShape()
  [ pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt1 ]
  ->Array.forEach(pt => {
    let (u, v) = pt
    P5.vertex(u, v)
  })
  P5.endShape(P5.close)
}

let drawArrowByIndex = (i: int, j: int) => {
  let offsetX = padding
  let offsetY = padding + halfBoxSize
  let x = offsetX + i * cellSize
  let y = offsetY + j * cellSize
  drawArrow(x, y)
}

let drawQueue = (arr: array<int>, maxLen: int):unit => {
  let offsetIdx = 2
  arr->Array.toReversed->Array.forEachWithIndex((v, i) => {
    drawBoxByIndex(string_of_int(v), i+offsetIdx, 1)
  })
  let offsetX = padding + offsetIdx * cellSize + cellSize / 2
  let offsetY = padding + cellSize
  let sx1 = offsetX - cellSize / 2 - padding
  let sx2 = sx1 + maxLen * cellSize
  let sy1 = offsetY - padding
  let sy2 = offsetY + cellSize - padding
  P5.strokeWeight(2*DrawUtil.strokeWeight)
  P5.strokeColor(ColorCode.black)
  P5.line(sx1, sy1, sx2, sy1)
  P5.line(sx1, sy2, sx2, sy2)
}

let loadProgram = (): array<code> => {
  let textbox = Jq.make("#program")
  let text = textbox->Jq.getValue()
  let enqueueRegExp = RegExp.fromString("enqueue\\((\\d+)\\)")
  let dequeueRegExp = RegExp.fromString("dequeue\\(\\)")
  let result: array<code> = []
  String.split(text, "\n")->Array.forEach(line => {
    switch RegExp.exec(enqueueRegExp, line) {
    | Some(m) =>
      let s = m->RegExp.Result.matches->Array.getUnsafe(0)
      let n = Int.fromString(s)->Option.getExn
      result->Array.push(EnqueueShow(n))
      result->Array.push(Enqueue(n))
    | None =>
      if RegExp.test(dequeueRegExp, line) {
        result->Array.push(Dequeue)
        result->Array.push(DequeuePause)
      }
    }
  })
  result
}

let runQueue = (program: array<code>, end:int): queueState => {
  let arr = []
  let rec rs = (i:int, output: option<int>) => {
    if end < i {
      (arr, output)
    } else {
      let code = program->Array.getUnsafe(i)
      let v: option<int> = switch code {
      | EnqueueShow(n) => Some(n)
      | Enqueue(n) => arr->Array.push(n); None
      | Dequeue => arr->Array.shift
      | DequeuePause => None
      }
      rs(i+1, v)
    }
  }
  rs(0, None)
}

let getQueueState = (program: array<code>, i: int): queueState => {
  if 0 <= i && i < program->Array.length {
    runQueue(program, i)
  } else {
    ([], None)
  }
}

let getMaxQueueLength = (program: array<code>): int => {
  Array.fromInitializer(~length=program->Array.length, i => {
    let (queue, _) = getQueueState(program, i)
    queue->Array.length
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

let isCode = (program: array<code>, i: int, op: [#enqueue | #dequeue]): bool => {
  switch program[i] {
  | Some(c) =>  switch c {
    | EnqueueShow(_) => op == #enqueue
    | Dequeue => op == #dequeue
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
    let len = program->getMaxQueueLength
    let (queue, output) = program->getQueueState(idx)
    drawLabel(program, idx)
    drawQueue(queue, len)
    if isCode(program, idx, #enqueue) {
      drawArrowByIndex(1, 1)
      drawBoxByIndex(string_of_int(output->Option.getExn), 0, 1)
    } else if isCode(program, idx, #dequeue) {
      drawArrowByIndex(len+2, 1)
      drawBoxByIndex(string_of_int(output->Option.getExn), len+3, 1)
    }
    refreshButtons()
  | None => ()
  }
}

let setHeight: string => unit = %raw(`id => $(id).height($(id)[0].scrollHeight)`)

let initializeQueue = () => {
  let id = "#program"
  let textbox = Jq.make(id)
  textbox->Jq.setValue([
    "enqueue(4)",
    "enqueue(2)",
    "enqueue(9)",
    "dequeue()",
    "enqueue(1)",
    "dequeue()",
    "enqueue(9)",
    "enqueue(7)",
    "enqueue(6)",
  ]->Array.join("\n"))->ignore
  setHeight(id)
}

let setup = () => {
  P5.createCanvas(0, 0)->P5.parent("canvas-hole")
  setDisable("#prev", true)
  setDisable("#next", true)
  initializeQueue()
}

let createCanvas = () => {
  let canvasHeight = cellSize * 3
  let canvasWidth = cellSize * (loadProgram()->getMaxQueueLength + 4)
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
