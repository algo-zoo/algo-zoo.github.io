let boxSize = 50
let canvasHeight = 200

let addLog = (text: string): unit => {
  let textbox = Jq.make("#textbox")
  let v = textbox->Jq.getValue()
  textbox->Jq.setValue(v ++ text ++ "\n")->ignore
}

let getRandomArray = (size: int): array<int> => {
  let maxVal = Js.Math.max_int(100, size * 5)
  Array.fromInitializer(~length=size, _ => 
    int_of_float(Math.floor(Math.random() *. float_of_int(maxVal)))
  )->Array.toSorted((x, y) => float_of_int(x) -. float_of_int(y))
}

let getTarget = (): int => {
  let targetText = Jq.make("#target")->Jq.getValue()
  NumberGuess.parseIntWithDefault(targetText)
}

type mode = Start | Range | CalcMid | End

type stateType = {
  left: ref<int>,
  right: ref<int>,
  mode: ref<mode>,
  compare_cnt: ref<int>,
  arr: ref<array<int>>
}

let state:stateType = {
  left: ref(0),
  right: ref(0),
  mode: ref(Start),
  compare_cnt: ref(0),
  arr: ref(Array.make(~length=0, 0))
}

let setup = () => {
  let canvasWidth = boxSize * (Array.length(state.arr.contents) + 2)
  P5.createCanvas(canvasWidth, canvasHeight)->P5.parent("canvas-hole")
  P5.textSize(20)
  P5.noLoop()
}

let refreshState = () => {
  let arrText = Jq.make("#array")->Jq.getValue()
  let arr = arrText
            ->String.split(",")
            ->Array.map(x => Int.fromString(x))
            ->Array.filterMap(x => x)
  state.left := 0
  state.right := Array.length(arr) - 1
  state.mode := Start
  state.compare_cnt := 0
  state.arr := arr
  Jq.make("#textbox")->Jq.setValue("")->ignore
}

let initializeRandomArray = () => {
  let sizeText = Jq.make("#size")->Jq.getValue()
  let s = NumberGuess.parseIntWithDefault(sizeText)
  if s <= 0 {
    Window.alert("配列の要素数は1以上の自然数を指定してください．")
  } else {
    let arr = getRandomArray(s)
    let arrText = Array.toString(arr)
    Jq.make("#array")->Jq.setValue(arrText)->ignore
  }
}

let drawIndex = (i:int) => {
  let x = (i+1)*boxSize
  let y = (canvasHeight + boxSize) / 2
  P5.fillColor(ColorCode.black)
  P5.textAlign(P5.center, P5.center)
  P5.text(string_of_int(i), x+boxSize/2, y+boxSize/2)
}

let drawElement = (v: int, i:int) => {
  let x = (i+1)*boxSize
  let y = (canvasHeight - boxSize) / 2

  P5.fillColor(
    if state.mode.contents == End && state.left.contents == i && state.arr.contents->Array.getUnsafe(i) == getTarget() {
      ColorCode.red
    } else if state.left.contents <= i && i <= state.right.contents {
      ColorCode.blue
    } else {
      ColorCode.lightGray
    }
  )
  P5.rect(x, y, boxSize, boxSize)

  P5.fillColor(ColorCode.black)
  P5.textAlign(P5.center, P5.center)
  P5.text(string_of_int(v), x+boxSize/2, y+boxSize/2)
}

let getMidium = (): int => {
  int_of_float(Math.floor(float_of_int(state.left.contents + state.right.contents) /. 2.0))
}

let drawArrow = (i:int) => {
  let x = (i+1)*boxSize + boxSize/2
  let y = canvasHeight/2 - boxSize*16/10

  P5.fillColor(
    if state.mode.contents == End && state.arr.contents->Array.getUnsafe(i) == getTarget() {
      ColorCode.red
    } else if i == getMidium() {
      ColorCode.yellow
    } else {
      ColorCode.white
    }
  )

  let (a, b, c) = (boxSize/10, boxSize/2, boxSize/4)
  P5.beginShape()
  [ (x-a, y), (x+a, y), (x+a, y+b), (x+c, y+b), (x, y+50), (x-c, y+b), (x-a, y+b) ]
  ->Array.forEach(((x, y)) => P5.vertex(x, y))
  P5.endShape(P5.close)
}

let draw = () => {
  P5.backgroundGray(200)
  state.arr.contents->Array.forEachWithIndex((v, i) => {
    drawElement(v, i)
    drawIndex(i)
  })
  if state.mode.contents == Range || state.mode.contents == CalcMid {
    drawArrow(state.left.contents)
    drawArrow(state.right.contents)
  }
  if state.mode.contents == CalcMid {
    drawArrow(getMidium())
  }
  if state.mode.contents == End && state.arr.contents->Array.getUnsafe(state.left.contents) == getTarget() {
    drawArrow(state.left.contents)
  }
}

let nextState = () => {
  if state.mode.contents == Start {
    state.mode := Range
    addLog("left: " ++ string_of_int(state.left.contents) ++ ", right: " ++ string_of_int(state.right.contents))
  } else {
    let mid = getMidium()
    let midValue = state.arr.contents->Array.getUnsafe(mid)
    let tarValue = getTarget()

    if state.mode.contents == Range {
      addLog("left: " ++ string_of_int(state.left.contents) ++ ", right: " ++ string_of_int(state.right.contents) ++ ", mid: " ++ string_of_int(mid) ++ " (= (left+right)/2 の小数点切り捨て )．");

      let message = "【" ++ string_of_int(state.compare_cnt.contents) ++ "回目の比較】";
      let tailMessage = if midValue == tarValue {
        "中間値 (= arr[mid] = " ++ string_of_int(midValue) ++ " ) == 探索値 (= " ++ string_of_int(tarValue) ++ " )が成立．";
      } else if midValue < tarValue {
        "中間値 (= arr[mid] = " ++ string_of_int(midValue) ++ " ) < 探索値 (= " ++ string_of_int(tarValue) ++ " )が成立． leftにmid++1 (= " ++ string_of_int(mid+1) ++ " )を代入．";
      } else {
        "探索値 (= " ++ string_of_int(tarValue) ++ " ) < 中間値 (= arr[mid] = " ++ string_of_int(midValue) ++ " )が成立． rightにmid-1 (= " ++ string_of_int(mid-1) ++ " )を代入．";
      }
      addLog(message ++ tailMessage)
      state.mode := CalcMid
      state.compare_cnt := state.compare_cnt.contents + 1
    } else if state.mode.contents == CalcMid {
      if midValue < tarValue {
        state.left := mid+1
      } else if midValue > tarValue {
        state.right := mid-1
      }

      if midValue == tarValue {
        state.left := mid
        state.mode := End
        addLog("値を発見．探索終了．")
      } else if state.left.contents > state.right.contents {
        state.mode := End
        addLog("left: " ++ string_of_int(state.left.contents) ++ ", right: " ++ string_of_int(state.right.contents))
        addLog("探索範囲内に値を発見できず．探索終了．")
      } else {
        state.mode := Range
        addLog("left: " ++ string_of_int(state.left.contents) ++ ", right: " ++ string_of_int(state.right.contents))
      }
    }
  }
}

let run = () => {
  nextState()
  P5.redraw()
}

let reset = () => {
  refreshState()
  P5.redraw()
}

let generate = initializeRandomArray

let set = () => {
  refreshState()
  setup()
  P5.redraw()
}

Jq.domMake(Jq.document)->Jq.ready(() => {
  [
    ("#run", run),
    ("#reset", reset),
    ("#generate", generate),
    ("#set", set)
  ]->Array.forEach(((id, f)) => Jq.make(id)->Jq.on("click", f))
})

Window.window["setup"] = setup
Window.window["draw"] = draw
