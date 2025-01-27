import { color_code } from './color-code.js'

const box_size = 150;
const text_size = 60;
const stroke_weight = 6;

const DUMMY = null;
const INSERT = 0;
const DELETE = 1;

class CompleteBinaryTree {
  setArray(arr) {
    this.arr = arr;
    redraw();
  }

  setup(max_array_size) {
    const w = box_size * (1 * max_array_size + 2);
    const h = box_size * (2 * Math.ceil(Math.log2(max_array_size)+0.00001) + 2);
    createCanvas(w, h).parent('canvas-hole');
    textSize(text_size);
    noLoop();
  }

  draw() {
    background(200);
    this.drawArray();
    this.drawTree();
  }

  drawElement(x, y, v, color) {
    strokeWeight(stroke_weight);
    fill.apply(null, color);
    rect(x, y, box_size, box_size);
    if (v != DUMMY) {
      textAlign(CENTER, CENTER);
      fill.apply(null, color_code.black);
      text(v, x+box_size/2, y+box_size/2)
    }
  }

  drawIndex(x, y, idx_value) {
    textAlign(CENTER, CENTER);
    fill.apply(null, color_code.black);
    text(idx_value, x+box_size/2, y+box_size*1.5)
  }

  drawArray() {
    for (let i = 0; i < this.arr.length; i++) {
      const x_offset = box_size;
      const x = i*box_size + x_offset;
      const y_offset = 0.5 * box_size;
      const y = box_size + y_offset;
      this.drawElement(x, y, this.arr[i], color_code.blue);
      this.drawIndex(x, y, i);
    }
  }

  drawNode(x, y, v, color) {
    strokeWeight(stroke_weight);
    fill.apply(null, color);
    ellipse(x, y, box_size, box_size);
    textAlign(CENTER, CENTER);
    fill.apply(null, color_code.black);
    text(v, x, y)
  }

  makeNode(v, level, count_from_left, left=null, right=null) {
    const x_offset = 1.25 + box_size;
    const y_offset = 4.5 * box_size;
    const x = count_from_left * box_size + x_offset;
    const y = (level + (level-1) * 0.5) * box_size + y_offset;
    return {
      value: v,
      x: (left && right) ? (left.x + right.x)/2 : x,
      y: y,
      left: left,
      right: right
    }
  }

  makeTree(arr, idx, level, count_from_left) {
    const element = idx < arr.length;
    const child = 2*idx+1 < arr.length;
    if (!element) {
      return [count_from_left, null];
    } else if (!child) {
      const node = this.makeNode(arr[idx], level, count_from_left);
      return [count_from_left+1, node];
    } else {
      const [cnt1, left] = this.makeTree(arr, 2*idx+1, level+1, count_from_left);
      const [cnt2, right] = this.makeTree(arr, 2*idx+2, level+1, cnt1+1);
      const node = this.makeNode(arr[idx], level, cnt1, left, right);
      return [cnt2, node];
    }
  }

  drawSegment(x1, y1, x2, y2) {
    strokeWeight(stroke_weight);
    line(x1, y1, x2, y2);
  }

  drawTreeEdgeRec(tree) {
    if (tree && tree.value != DUMMY) {
      this.drawTreeEdgeRec(tree.left);
      this.drawTreeEdgeRec(tree.right);
      if (tree.left && tree.left.value != DUMMY)
        this.drawSegment(tree.x, tree.y, tree.left.x, tree.left.y);
      if (tree.right && tree.right.value != DUMMY)
        this.drawSegment(tree.x, tree.y, tree.right.x, tree.right.y);
    }
  }

  drawTreeRec(tree) {
    if (tree && tree.value != DUMMY) {
      this.drawTreeRec(tree.left);
      this.drawTreeRec(tree.right);
      this.drawNode(tree.x, tree.y, tree.value, color_code.white);
    }
  }

  drawTree() {
    const [_, tree] = this.makeTree(this.arr, 0, 0, 0);
    this.drawTreeEdgeRec(tree);
    this.drawTreeRec(tree);
  }
}

export class Heap {
  constructor() {
    this.cbt = new CompleteBinaryTree();
    this.reset_value();
  }

  compare(x, y) {
    alert('Implementation Error: The function "compare" must be implemented.');
  }

  setup() {
    this.initialize();
    this.cbt.setup(this.max_size);
    redraw();
  }

  reset_value() {
    this.max_size = null;
    this.heap = [];
    this.logs = [];
    this.idx = 0;
  }

  reset() {
    this.reset_value();
    this.refresh();
  }

  refresh() {
    $('#prev').prop('disabled', this.logs.length == 0 || this.idx == 0);
    $('#next').prop('disabled', this.logs.length == 0 || this.idx+1 == this.logs.length);
    redraw();
  }

  prev() {
    if (this.idx > 0) {
      this.idx -= 1;
      this.refresh();
    }
  }

  next() {
    if (this.idx+1 < this.logs.length) {
      this.idx += 1;
      this.refresh();
    }
  }

  draw() {
    const log = this.logs[this.idx];
    if (log && log.array.length >= 0) {
      this.cbt.setArray(log.array);
      this.cbt.draw();
      this.drawLabel(log.label);
    }
  }

  drawLabel(label) {
    textAlign(LEFT);
    fill.apply(null, color_code.red);
    text(label, box_size, box_size);
  }

  loadCommands() {
    const commands = [];
    for (const txt of $('#program').val().split(/\r?\n/)) {
      const m = txt.match(/^insert\((\d+)\)$/);
      if (m) {
        commands.push({ opcode: INSERT, value: parseInt(m[1])});
      } else if (txt.match(/^delete\(\)$/)) {
        commands.push({ opcode: DELETE });
      } else if (!txt.match(/^\s*$/)) {
        alert("ERROR: \"" + txt + "\"");
      }
    }
    return commands;
  }

  heapSwap(i, j) {
    const tmp = this.heap[i];
    this.heap[i] = this.heap[j];
    this.heap[j] = tmp;
  }
  
  parentIndex(k) {
    return Math.floor((k-1)/2);
  }

  leftChildIndex(k) {
    return 2*k + 1;
  }

  rightChildIndex(k) {
    return 2*k + 2;
  }

  hasLeftChild(k) {
    return this.leftChildIndex(k) < this.heap.length;
  }

  hasRightChild(k) {
    return this.rightChildIndex(k) < this.heap.length;
  }


  heapify(i) {
    if (i == 0)
      return;
    const p = this.parentIndex(i);
    if (this.compare(this.heap[p], this.heap[i])) {
      this.heapSwap(p, i);
      this.heapify(p);
    }
  }
  
  heapInsert(v) {
    this.heap.push(v);
    this.heapify(this.heap.length-1);
  }
  heapDelete() {
    if (this.heap.length == 0)
      return;
  
    this.heap[0] = this.heap[this.heap.length-1];
    this.heap.pop();
  
    var i = 0;
    while (this.hasLeftChild(i)) {
      var max_child = this.leftChildIndex(i);
      if (this.hasRightChild(i)) {
        var right_child = this.rightChildIndex(i);
        if (this.compare(this.heap[max_child], this.heap[right_child])) {
          max_child = right_child;
        }
      }
  
      if (this.compare(this.heap[i], this.heap[max_child])) {
        this.heapSwap(i, max_child);
        i = max_child;
      } else {
        break;
      }
    }
  }

  initialize() {
    this.reset_value();
  
    const commands = this.loadCommands();
    var sz = 0;
    this.max_size = 0;
    for (const command of commands) {
      sz += command.opcode == INSERT ? 1 : -1;
      this.max_size = Math.max(this.max_size, sz);
    }
  
    const addLog = function(label) {
      const tmp = Array.from(this.heap);
      while (tmp.length < this.max_size)
        tmp.push(DUMMY);
      this.logs.push({ label: label, array: tmp });
    }.bind(this);
    addLog('');
    for (const command of commands) {
      if (command.opcode == INSERT) {
        this.heapInsert(command.value);
        addLog('insert(' + command.value.toString() + ')');
      } else if (command.opcode == DELETE) {
        this.heapDelete();
        addLog('delete()');
      }
    }
  }
}

