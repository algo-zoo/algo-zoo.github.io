import { color_code } from './color-code.js'

const mode = {
  START: 1,     // 0001
  RANGE: 2,     // 0010
  CALC_MID: 4,  // 0100
  END: 8        // 1000
}
var cv = { // constant values
  w: 0,
  h: 200,
  box_size: 50,
}
var arr = [];
var state;
var target = NaN;

window.setup = function() {
  initializeState();
  cv.w = cv.box_size * (arr.length + 2);
  createCanvas(cv.w, cv.h).parent('canvas-hole');
  textSize(20);
  noLoop();
}

const drawArrow = function(i) {
  const x = (i+1)*cv.box_size + cv.box_size/2;
  const y = cv.h/2 - cv.box_size*16/10;

  if ((state.mode & mode.END) && (arr[i] == target)) {
    fill.apply(null, color_code.red);
  } else {
    fill.apply(null, i == getMidium() ? color_code.yellow : color_code.white);
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
    fill.apply(null, state.left == i && arr[i] == target ? color_code.red : color_code.gray);
  } else {
    fill.apply(null, state.left <= i && i <= state.right ? color_code.blue : color_code.gray);
  }
  rect(x, y, cv.box_size, cv.box_size);
  textAlign(CENTER, CENTER);
  fill.apply(null, color_code.black);
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

const getRandomArray = function(size) {
  const tmp = [];
  for (let i = 0; i < size; i++)
    tmp.push(Math.floor(Math.random() * Math.max(100, size * 5)));
  tmp.sort((x, y) => x-y);
  return tmp;
}

const initializeRandomArray = function() {
  const s = $('#size').val();
  if (s <= 0) {
    alert('配列の要素数は1以上の自然数を指定してください．')
  } else {
    arr = getRandomArray(s);
    $('#array').val(String(arr));
  }
}

const initializeState = function() {
  state = { left: 0, right: arr.length-1, mode: mode.START, compare_cnt: 0 };
}

const reset = function() {
  arr = eval("[" + $('#array').val() + "]");
  initializeState();
  $('#textbox').val('');
}

const addLog = function(txt) {
  $('#textbox').val($('#textbox').val() + txt + "\n");
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
