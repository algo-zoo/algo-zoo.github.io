let boxSize = 2 * int_of_float(Math.sqrt(2.0) *. Int.toFloat(DrawUtil.nodeRadius))

type code = Push(int)| Pop

type stateType = {
  index: ref<option<int>>
}

let state:stateType = {
  index: ref(None)
}

let drawBox = (x: int, y: int):unit => {
  P5.strokeWeight(DrawUtil.strokeWeight)
  P5.fillColor(ColorCode.lightBlue)
  P5.rect(x-boxSize/2, y-boxSize/2, boxSize, boxSize)
}

let drawLabel = (program: array<code>, i: int) => {
  let offsetX = boxSize
  let offsetY = boxSize * 3 / 2
  switch program[i] {
  | Some(c) =>
    let label = switch c {
    | Push(n) => "push(" ++ string_of_int(n) ++ ")"
    | Pop     => "pop()"
    }
    P5.textSize(40)
    P5.textAlign(P5.left, P5.baseline)
    P5.text(label, offsetX, offsetY)
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

let getStackState = (program: array<code>, i: int): array<int> => {
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

let draw = () => {
  P5.backgroundGray(200)

  switch state.index.contents {
  | Some(idx) =>
    let program = loadProgram()
    drawLabel(program, idx)
    let stack = getStackState(program, idx)
    drawStack(stack)
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
  let canvasHeight = boxSize * 5
  let canvasWidth = 1000
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
