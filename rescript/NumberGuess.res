let parseIntWithDefault = (s: string): int =>
  switch Int.fromString(s) {
  | Some(i) => i
  | None => 0
  }

let getRange = (): (int, int) => {
  let b = parseIntWithDefault(Jq.make("#begin")->Jq.getValue()) - 1
  let e = parseIntWithDefault(Jq.make("#end")->Jq.getValue())
  (b, e)
}

let getTarget = (): int =>
  parseIntWithDefault(Jq.make("#target")->Jq.getValue())

let setTarget = (v: int): unit =>
  Jq.make("#target")->Jq.setValue(string_of_int(v))->ignore

let setRandomTarget = (): unit => {
  let (b, e) = getRange()
  let randomOffset = int_of_float (Math.floor (Math.random() *. float_of_int(e - b)))
  setTarget(b + randomOffset + 1)
}

let makeColorBar = (x: int, y: int): Jq.t => {
  let (b, e) = getRange()
  let barB = (float_of_int(x - b)) /. (float_of_int(e - b)) *. 100.0
  let barE = (float_of_int(y - b)) /. (float_of_int(e - b)) *. 100.0
  let barWidth = barE -. barB
  let colorBar = (color: string, r: float): Jq.t => {
    let style = "width: calc(" ++ Float.toString(r) ++ "% - 1px)"
    Jq.make("<div class='" ++ color ++ "' style='" ++ style ++ "'>&nbsp;</div>")
  }
  Jq.make("<div class='bar'></div>")->Jq.append([
    colorBar("gray-bar", barB),
    colorBar("blue-bar", barWidth),
    colorBar("gray-bar", 100.0 -. (barB +. barWidth))
  ])
}

let makeBar = (text: string, x: int, y: int): Jq.t => {
  let textTag = Jq.make("<div class='header-left'></div>")->Jq.text(text)
  let rangeText = "【探索範囲=" ++ string_of_int(x+1) ++ "~" ++ string_of_int(y) ++ ", 幅=" ++ string_of_int(y - x) ++ "】"
  let rangeTag = Jq.make("<div class='header-right'></div>")->Jq.text(rangeText)
  let colorBar = makeColorBar(x, y)
  Jq.make("<div></div>")->Jq.append([ textTag, rangeTag, colorBar])
}

let makeRow = (a: string, b: [#text(string) | #jq(Jq.t)]): Jq.t => {
  let tdA = Jq.make("<td></td>")->Jq.css("width", "10%")->Jq.appendText(a)
  let tmp = Jq.make("<td></td>")->Jq.css("width", "90%")
  let tdB = switch b {
    | #text(t) => tmp->Jq.appendText(t)
    | #jq(v) => tmp->Jq.append([ v ])
  }
  Jq.make("<tr></tr>")->Jq.append([ tdA, tdB ])
}

let binarySearch = (): unit => {
  let (b, e) = getRange()
  let target = getTarget()
  if e < b {
    Window.alert("エラー: 始点は終点以下の値を指定してください")
  } else if target < b || target > e {
    Window.alert("エラー: 答えの数値は探索範囲内を指定してください")
  } else {
    let tbody = Jq.make("#chat")->Jq.empty->Jq.append([
      Jq.make("<tbody></tbody>")
    ])
    let initText = "🤡（…… 答えの数は " ++ string_of_int(target) ++ " だ！ ……）"
    let _ = makeRow("初期状態", #jq(makeBar(initText, b, e)))->Jq.appendTo(tbody)
    let rec loop = (level: int, b: int, e: int): int =>
      if e - b >= 2 {
        let mid = (b + e) / 2
        let headText = string_of_int(level) ++ "回目"
        let baseText = "🤔「" ++ string_of_int(mid) ++ "以下か？」 ⇒ "
        if target <= mid {
          let text = baseText ++ "🤡「Yes」"
          let _ = makeRow(headText, #jq(makeBar(text, b, mid)))->Jq.appendTo(tbody)
          loop(level + 1, b, mid)
        } else {
          let text = baseText ++ "🤡「No」"
          let _ = makeRow(headText, #jq(makeBar(text, mid, e)))->Jq.appendTo(tbody)
          loop(level + 1, mid, e)
        }
      } else {
        e
      }
    let value = loop(1, b, e)
    let _ = makeRow("答え", #text(string_of_int(value)))->Jq.appendTo(tbody)
  }
}

Jq.domMake(Jq.document)->Jq.ready(() => {
  Jq.make("#random")->Jq.on("click", setRandomTarget)
  Jq.make("#binary")->Jq.on("click", binarySearch)
  setRandomTarget()
})
