%%raw(`
import { color_code } from './color-code.js'

class MergeSort {
  constructor() {
    this.w = -1;
    this.h = -1;
    this.box_size = 100;
    this.text_size = 40;
    this.arr = [];
    this.target = NaN;
  }

  setup() {
    const len = this.arr.length;
    this.w = this.box_size * (2 * len + 1);
    this.h = this.box_size * (4 * Math.ceil(Math.log2(len) + 1) + 2);
    createCanvas(this.w, this.h).parent('canvas-hole');
    textSize(this.text_size);
    noLoop();
  }

  draw() {
    background(200);
    if (this.arr.length > 0) {
      this.drawMergeSort(this.arr);
    }
  }

  drawElement(x, y, v, color) {
    fill.apply(null, color);
    rect(x, y, this.box_size, this.box_size);
    textAlign(CENTER, CENTER);
    fill.apply(null, color_code.black);
    text(v, x+this.box_size/2, y+this.box_size/2)
  }
  
  drawIndex(x, y, idx_value) {
    text(idx_value, x+this.box_size/2, y+this.box_size*1.5)
  }
  
  devide(data, level_offset, level, left, right) {
    const current_level = level_offset + level;
    const y = (2*current_level + 1) * this.box_size;
    if (right - left == 1) {
      const x = (2*left + 1) * this.box_size;
      return [level, x, x+this.box_size];
    } else {
      const mid = left + Math.floor((right - left)/2);
      const data_left = data.slice(left, mid);
      const data_right = data.slice(mid, right);
      const [l1, x1, x2] = this.devide(data, level_offset, level+1, left, mid);
      const [l2, x3, x4] = this.devide(data, level_offset, level+1, mid, right);
      for (let i = 0; i < data_left.length; i++) {
        const x = x1 + i*this.box_size + (x2-x1)/4;
        this.drawElement(x, y, data_left[i], color_code.blue);
        this.drawIndex(x, y, left+i);
      }
      for (let i = 0; i < data_right.length; i++) {
        const x = x3 + i*this.box_size + (x4-x3)/4;
        this.drawElement(x, y, data_right[i], color_code.blue);
        this.drawIndex(x, y, mid+i);
      }
      return [max(l1, l2), x1, x4];
    }
  }
  
  merge(data, max_level, level_offset, level, left, right) {
    const current_level = max_level - level;
    const y = (2*current_level + 1) * this.box_size;
    if (right - left == 1) {
      const x = (2*left + 1) * this.box_size;
      return [x, x+this.box_size];
    } else {
      const mid = left + Math.floor((right - left)/2);
      const data_left = sort(data.slice(left, mid));
      const data_right = sort(data.slice(mid, right));
      const [x1, x2] = this.merge(data, max_level, level_offset, level+1, left, mid);
      const [x3, x4] = this.merge(data, max_level, level_offset, level+1, mid, right);
      for (let i = 0; i < data_left.length; i++) {
        const x = x1 + i*this.box_size + (x2-x1)/4;
        this.drawElement(x, y, data_left[i], color_code.yellow);
        this.drawIndex(x, y, left+i);
      }
      for (let i = 0; i < data_right.length; i++) {
        const x = x3 + i*this.box_size + (x4-x3)/4;
        this.drawElement(x, y, data_right[i], color_code.yellow);
        this.drawIndex(x, y, mid+i);
      }
      return [x1, x4];
    }
  }
  
  drawArray(data, level, color) {
    for (let i = 0; i < data.length; i++) {
      const x = i*this.box_size + (data.length / 2) * this.box_size;
      const y = (2*level+1) * this.box_size;
      this.drawElement(x, y, data[i], color);
      this.drawIndex(x, y, i);
    }
  }
  
  drawMergeSort(data) {
    this.drawArray(data, 0, color_code.blue);
    var [l1, _, _] = this.devide(data, 1, 0, 0, data.length);
    const max_level = 2*l1;
    this.merge(data, max_level, l1, 0, 0, data.length);
    this.drawArray(sort(data), max_level+1, color_code.yellow);
  }
  
  initializeRandomArray() {
    const getRandomArray = function(size) {
      var tmp = [];
      for (let i = 0; i < size; i++)
        tmp.push(Math.floor(Math.random() * Math.max(100, size * 5)));
      return tmp;
    }

    const s = $('#size').val();
    if (s <= 0) {
      alert('配列の要素数は1以上の自然数を指定してください．')
    } else {
      this.arr = getRandomArray(s);
      $('#array').val(String(this.arr));
    }
  }
  
  reset() {
    this.arr = eval("[" + $('#array').val() + "]");
    $('#textbox').val('');
  }
}

const ms = new MergeSort();
window.setup = ms.setup.bind(ms);
window.draw = ms.draw.bind(ms);

$(document).ready(function () {
  $('#generate').click(() => ms.initializeRandomArray());
  $('#set').click(function() {
    ms.reset();
    $('#size').val(ms.arr.length);
    ms.setup();
    redraw();
  });
});
`)
