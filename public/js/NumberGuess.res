module Jq = {
  type t
  @val external make: string => t = "$"
  @val external document: t = "document"
  @val external domMake: t => t = "$"
  @send external val: (t, option<string>) => string = "val"
  @send external setVal: (t, string) => t = "val"
  @send external append: (t, array<t>) => t = "append"
  @send external appendTo: (t, t) => t = "appendTo"
  @send external css: (t, string, string) => t = "css"
  @send external on: (t, string, (unit => unit)) => t = "on"
  @send external empty: t => t = "empty"
  @send external text: (t, string) => t = "text"
  @send external ready: (t, (unit => unit)) => t = "ready"
}

module Window = {
  external alert: string => unit = "alert"
}

let parseIntWithDefault = (s: string): int =>
  switch RescriptCore.Int.fromString(s) {
  | Some(i) => i
  | None => 0
  }

let getRange = (): (int, int) => {
  let beginVal = Jq.make("#begin")->Jq.val(None)
  let endVal = Jq.make("#end")->Jq.val(None)
  let b = parseIntWithDefault(beginVal) - 1
  let e = parseIntWithDefault(endVal)
  (b, e)
}

let getTarget = (): int =>
  parseIntWithDefault(Jq.make("#target")->Jq.val(None))

let setTarget = (v: int): unit =>
  ignore(Jq.make("#target")->Jq.setVal(string_of_int(v)))

let setRandomTarget = (): unit => {
  let (b, e) = getRange()
  let range = e - b
  let randomOffset : int = int_of_float (RescriptCore.Math.floor (RescriptCore.Math.random() *. float_of_int(range)))
  setTarget(b + randomOffset + 1)
}

let makeColorBar = (x: int, y: int): Jq.t => {
  let (b, e) = getRange()
  let barB = (float_of_int(x - b)) /. (float_of_int(e - b)) *. 100.0
  let barE = (float_of_int(y - b)) /. (float_of_int(e - b)) *. 100.0
  let barWidth = barE -. barB

  let colorBar = (color: string, r: float): Jq.t => {
    let style = "width: calc(" ++ RescriptCore.Float.toString(r) ++ "% - 1px)"
    Jq.make("<div class='" ++ color ++ "' style='" ++ style ++ "'>&nbsp;</div>")
  }

  let grayBar1 = colorBar("gray-bar", barB)
  let blueBar = colorBar("blue-bar", barWidth)
  let grayBar2 = colorBar("gray-bar", 100.0 -. (barB +. barWidth))
  Jq.make("<div class='bar'></div>")
  ->Jq.append([ grayBar1, blueBar, grayBar2 ])
}

let makeBar = (text: string, x: int, y: int): Jq.t => {
  let textTag = Jq.make("<div class='header-left'></div>")
  ->Jq.text(text)
  let rangeText = "【探索範囲=" ++ string_of_int(x+1) ++ "~" ++ string_of_int(y) ++ ", 幅=" ++ string_of_int(y - x) ++ "】"
  let rangeTag = Jq.make("<div class='header-right'></div>")
  ->Jq.text(rangeText)
  let colorBarElem = makeColorBar(x, y)
  Jq.make("<div></div>")
  ->Jq.append([ textTag, rangeTag, colorBarElem ])
}

let makeRow = (a: string, b: Jq.t): Jq.t => {
  let tdA = Jq.make("<td></td>")->Jq.css("width", "10%")->Jq.append([ Jq.make(a) ])
  let tdB = Jq.make("<td></td>")->Jq.css("width", "90%")->Jq.append([ b ])
  Jq.make("<tr></tr>")->Jq.append([ tdA, tdB ])
}

let binarySearch = (): unit => {
  let (b, e) = getRange()
  let target = getTarget()
  if (e < b) {
    Window.alert("エラー: 始点は終点以下の値を指定してください")
  } else if (target < b || target > e) {
    Window.alert("エラー: 答えの数値は探索範囲内を指定してください")
  } else {
    let tbody = Jq.make("#chat")->Jq.empty->Jq.append([
      Jq.make("<tbody></tbody>")
    ])
    let initialText = "🤡（…… 答えの数は " ++ string_of_int(target) ++ " だ！ ……）"
    let bar = makeBar(initialText, b, e)
    let cb = ref(b)
    let ce = ref(e)
    makeRow("初期状態", bar)->Jq.appendTo(tbody)->ignore
    let rec loop = (cnt: int): unit =>
      if ((ce.contents - cb.contents) >= 2) {
        let mid = (cb.contents + ce.contents) / 2
        let baseText = "🤔「" ++ string_of_int(mid) ++ "以下か？」 ⇒ "
        if (target <= mid) {
          ce := mid
          let text = baseText ++ "🤡「Yes」"
          makeRow(string_of_int(cnt) ++ "回目", makeBar(text, cb.contents, ce.contents))
            ->Jq.appendTo(tbody)->ignore
          loop(cnt + 1)
        } else {
          cb := mid
          let text = baseText ++ "🤡「No」"
          makeRow(string_of_int(cnt) ++ "回目", makeBar(text, cb.contents, ce.contents))
            ->Jq.appendTo(tbody)->ignore
          loop(cnt + 1)
        }
      } else {
        ()
      }
    loop(1)
    makeRow("答え", Jq.make(string_of_int(ce.contents)))
      ->Jq.appendTo(tbody)->ignore
  }
}

Jq.domMake(Jq.document)->Jq.ready(() => {
  Jq.make("#random")->Jq.on("click", setRandomTarget)->ignore
  Jq.make("#binary")->Jq.on("click", binarySearch)->ignore
  setRandomTarget()->ignore
})->ignore
