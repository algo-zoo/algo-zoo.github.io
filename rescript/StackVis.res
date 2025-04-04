let boxSize = 2 * int_of_float(Math.sqrt(2.0) *. Int.toFloat(DrawUtil.nodeRadius))

type code = Push(int)| Pop

type stateType = {
  index: ref<int>
}

let state:stateType = {
  index: ref(0)
}

let drawBox = (x: int, y: int):unit => {
  P5.strokeWeight(DrawUtil.strokeWeight)
  P5.fillColor(ColorCode.lightBlue)
  P5.rect(x-boxSize/2, y-boxSize/2, boxSize, boxSize)
}

let drawLabel = (program: array<code>, i: int) => {
  switch program[i] {
  | Some(c) =>
    let label = switch c {
    | Push(n) => "push(" ++ string_of_int(n) ++ ")"
    | Pop     => "pop()"
    }
    P5.textSize(40)
    P5.textAlign(P5.left, P5.center)
    P5.text(label, boxSize, boxSize)
  | None => ()
  }
}

let drawStack = (arr: array<int>):unit => {
  let offsetX = boxSize * 3 / 2
  let offsetY = boxSize * 5 / 2
  let padding = 15

  arr->Array.toReversed->Array.forEachWithIndex((v, i) => {
    let x = offsetX + i * (boxSize + padding)
    let y = offsetY + boxSize / 2
    drawBox(x, y)
    DrawUtil.drawNode(x, y, string_of_int(v))
  })

  let n = arr->Array.length
  let sx1 = offsetX - boxSize/2 - padding
  let sx2 = sx1 + n * (boxSize + padding) + padding
  let sy1 = offsetY - padding
  let sy2 = offsetY + boxSize + padding
  P5.strokeWeight(2*DrawUtil.strokeWeight)
  P5.line(sx1, sy1, sx2, sy1)
  P5.line(sx1, sy2, sx2, sy2)
  P5.line(sx2, sy1, sx2, sy2)
}

let loadProgram = (): array<code> => {
  let textbox = Jq.make("#program")
  let text = textbox->Jq.getValue()
  let pushRegExp = RegExp.fromString("push\\((\\d+)\\)")
  let popRegExp = RegExp.fromString("pop\\(\\)")
  Array.keepSome(String.split(text, "\n")->Array.map(line => {
    switch RegExp.exec(pushRegExp, line) {
    | Some(m) =>
      let s = m->RegExp.Result.matches->Array.getUnsafe(0)
      Some(Push(Int.fromString(s)->Option.getExn))
    | None =>
      if RegExp.test(popRegExp, line) {
        Some(Pop)
      } else {
        None
      }
    }
  }))
}

let getStackState = (program: array<code>, i: int) => {
  let runStack = (end:int): array<int> => {
    let arr = []
    let rec rs = (i:int): array<int> => {
      if end < i {
        arr
      } else {
        let code = program->Array.getUnsafe(i)
        switch code {
        | Push(n) => arr->Array.push(n)
        | Pop     => arr->Array.pop->ignore
        }
        rs(i+1)
      }
    }
    rs(0)
  }
  if 0 <= i && i < program->Array.length {
    runStack(i)
  } else {
    []
  }
}

let draw = () => {
  P5.backgroundGray(200)

  let idx = state.index.contents
  let program = loadProgram()
  drawLabel(program, idx)
  let stack = getStackState(program, idx)
  drawStack(stack)
  Console.log2(idx, stack)
}

let createCanvas = () => {
  let canvasHeight = boxSize * 5
  let canvasWidth = 1000
  P5.createCanvas(canvasWidth, canvasHeight)->P5.parent("canvas-hole")
  P5.noLoop()
}

let initializeStack = () => {
  let textbox = Jq.make("#program")
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
  state.index := -1
}

let setup = () => {
  initializeStack()
  createCanvas()
}

let prev = () => {
  state.index := state.index.contents - 1
}

let next = () => {
  state.index := state.index.contents + 1
}

Jq.domMake(Jq.document)->Jq.ready(() => {
  [
    // ("#run", () => { P5.redraw() }),
    ("#prev", prev),
    ("#next", next),
  ]->Array.forEach(((id, f)) => Jq.make(id)->Jq.on("click", () => { f(); P5.redraw() }))
})

Window.window["setup"] = setup
Window.window["draw"] = draw
