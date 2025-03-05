/* BinarySearch.res */

module P5 = {
  type t
  @val external createCanvas: (int, int) => t = "createCanvas"
  @send external parent: (t, string) => unit = "parent"
  @val external textSize: int => unit = "textSize"
  @val external noLoop: unit => unit = "noLoop"
  @val external redraw: unit => unit = "redraw"
  @val external backgroundGray: int => unit = "background"
  @val external vertex: (int, int) => unit = "vertex"
  @val external rect: (int, int, int, int) => unit = "rect"
  @val external fillColor: ((int, int, int)) => unit = "fillColor"
}

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

type mode = Start | Range | CalcMid | End

type stateType = {
  left: int,
  right: int,
  mode: mode,
  compare_cnt: int,
  arr: array<int>
}

let state:ref<stateType> = ref({left: 0, right: 0, mode: Start, compare_cnt: 0, arr: Array.make(~length=0, 0)})

let setup = () => {
  let boxSize = 50
  let canvasWidth = boxSize * (Array.length(state.contents.arr) + 2)
  let canvasHeight = 200
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
  state := {left: 0, right: Array.length(arr)-1, mode: Start, compare_cnt: 0, arr: arr}
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

let draw = () => {
  P5.backgroundGray(200)
  P5.fillColor(ColorCode.red)
  P5.rect(30, 30, 20, 20)
}

%%raw(`
function fillColor(color_code) {
  fill.apply(null, color_code);
}
`)

%%raw(`
window.setup = setup;

window.draw = draw;
`)

let run = () => {
  P5.redraw()
}

let reset = () => {
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
  ]->Array.forEach(((id, f)) => Jq.make(id)->Jq.on("click", f)->ignore)
})->ignore

/*
%%raw(`
$(document).ready(function () {
  $('#run').click(function() {
    nextState();
    redraw();
  });
  $('#reset').click(function() {
    reset();
    redraw();
  });
  $('#generate').click(function() {
    initializeRandomArray();
  });
  $('#set').click(function() {
    reset();
    $('#size').val(arr.length);
    setup();
    redraw();
  });
});

var state;
var target = NaN;

const drawArrow = function(i) {
  const x = (i+1)*cv.box_size + cv.box_size/2;
  const y = cv.h/2 - cv.box_size*16/10;

  if ((state.mode & mode.END) && (arr[i] == target)) {
    fill.apply(null, red);
  } else {
    fill.apply(null, i == getMidium() ? yellow : white);
  }
  beginShape();
  const a = cv.box_size/10;
  const b = cv.box_size/2;
  const c = cv.box_size/4;
  vertex(x-a, y);
  vertex(x+a, y);
  vertex(x+a, y+b);
  vertex(x+c, y+b);
  vertex(x, y+50);
  vertex(x-c, y+b);
  vertex(x-a, y+b);
  endShape(CLOSE);
}

const drawElement = function(i) {
  const v = arr[i];
  const x = (i+1)*cv.box_size;
  const y = cv.h/2 - cv.box_size/2;
  if (state.mode & mode.END) {
    fill.apply(null, state.left == i && arr[i] == target ? red : gray);
  } else {
    fill.apply(null, state.left <= i && i <= state.right ? blue : gray);
  }
  rect(x, y, cv.box_size, cv.box_size);
  textAlign(CENTER, CENTER);
  fill.apply(null, black);
  text(v, x+cv.box_size/2, y+cv.box_size/2)
}

const drawIndex = function(i) {
  const x = (i+1)*cv.box_size;
  const y = cv.h/2 + cv.box_size/2;
  text(i, x+cv.box_size/2, y+cv.box_size/2)
}

const getMidium = function() {
  return floor(state.left + (state.right-state.left)/2);
}

const initializeState = function() {
  state = { left: 0, right: arr.length-1, mode: mode.START, compare_cnt: 0 };
}

const reset = function() {
  arr = eval("[" + $('#array').val() + "]");
  initializeState();
  $('#textbox').val('');
}

const nextState = function() {
  if (state.mode & mode.START) {
    target = $('#target').val();
    state.mode = mode.RANGE;
    addLog('left: ' + state.left + ", right: " + state.right);
  } else if (state.mode & mode.RANGE) {
    const mid = getMidium();
    const v = arr[mid];
    state.mode = mode.CALC_MID;
    addLog('left: ' + state.left + ", right: " + state.right + ", mid: " + mid + " (= (left+right)/2 の小数点切り捨て )．");

    state.compare_cnt++;
    let message = '【' + state.compare_cnt + '回目の比較】';
    if (arr[mid] == target) {
      message += '中間値 (= arr[mid] = ' + v + ' ) == 探索値 (= ' + target + ' )が成立．';
    } else if (arr[mid] < target) {
      message += '中間値 (= arr[mid] = ' + v + ' ) < 探索値 (= ' + target + ' )が成立． leftにmid+1 (= ' + (mid+1) + ' )を代入．';
    } else if (arr[mid] > target) {
      message += '探索値 (= ' + target + ' ) < 中間値 (= arr[mid] = ' + v + ' )が成立． rightにmid-1 (= ' + (mid-1) + ' )を代入．';
    }
    addLog(message);
  } else if (state.mode & mode.CALC_MID) {
    const mid = getMidium();
    if (arr[mid] < target) {
      state.left = mid+1;
    } else if (arr[mid] > target) {
      state.right = mid-1;
    }
    if (arr[mid] == target) {
      state.mode = mode.END;
      state.left = mid;
      addLog('値を発見．探索終了．')
    } else if (state.left > state.right) {
      state.mode = mode.END;
      addLog('left: ' + state.left + ", right: " + state.right);
      addLog('探索範囲内に値を発見できず．探索終了．')
    } else {
      addLog('left: ' + state.left + ", right: " + state.right);
      state.mode = mode.RANGE;
    }
  }
}

window.draw = function() {
  background(200);

  for (let i = 0; i < arr.length; i++) {
    drawElement(i);
    drawIndex(i);
  }
  if (state.mode & (mode.RANGE | mode.CALC_MID)) {
    drawArrow(state.left);
    drawArrow(state.right);
  }
  if (state.mode & mode.CALC_MID) {
    drawArrow(getMidium());
  }
  if ((state.mode & mode.END) && (arr[state.left] == target)) {
    drawArrow(state.left);
  }
}
`)
*/
