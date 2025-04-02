import { color_code } from './color-code.js'
import { calc_dist, calc_edge_point, rotation } from './draw-util.js'

const text_size = 24;
const canvas_w = 1000;
const canvas_h = 1000;

class V {
  constructor() {
    this.node_r = 25;
    this.nodes = [];
  }

  draw_node(node) {
    drawingContext.setLineDash([]);

    const node_d = this.node_r * 2;
    strokeWeight(2);
    stroke.apply(null, color_code.black);
    fill.apply(null, node.color);
    ellipse(node.x, node.y, node_d, node_d);

    textAlign(CENTER, CENTER);
    fill(0);
    textSize(text_size);
    text(node.label, node.x, node.y);
  }

  make(label, x, y, color=color_code.white) {
    return {
      label: label,
      x: x,
      y: y,
      color: color
    }
  }

  add(...args) {
    const v = this.make.apply(this, args);
    this.nodes.push(v);
  }

  modify(v, new_v) {
    this.nodes = this.nodes.map(u => u == v ? new_v : u);
  }

  get(i) {
    return this.nodes[i];
  }

  get_index(label) {
    return this.nodes.findIndex(x => x.label == label);
  }

  get_node_from_canvas(px, py) {
    return this.nodes.find(v => calc_dist(px, py, v.x, v.y) <= this.node_r);
  }

  get_nodes() {
    return this.nodes;
  }

  get_labels() {
    return this.nodes.map(v => v.label);
  }

  get_size() {
    return this.nodes.length;
  }

  draw() {
    this.nodes.forEach(this.draw_node, this);
  }
}

class E {
  constructor(V, directed) {
    this.V = V;
    this.edges = [];
    this.directed = directed;
  }

  draw_arrow_head(x1, y1, x2, y2, color) {
    strokeWeight(2);
    fill.apply(null, color);
    stroke.apply(null, color);
    const [ax, ay] = calc_edge_point(x2, y2, x1, y1, x2, y2, 10);
    const [bx, by] = rotation(x2, y2, ax, ay, Math.PI / 8);
    const [cx, cy] = rotation(x2, y2, ax, ay, -Math.PI / 8);
    triangle(x2, y2, bx, by, cx, cy);
  }

  draw_arrow(x1, y1, x2, y2, color) {
    strokeWeight(2);
    fill.apply(null, color);
    stroke.apply(null, color);
    line(x1, y1, x2, y2);
    if (this.directed)
      this.draw_arrow_head(x1, y1, x2, y2, color);
  }

  draw_curve_arrow(x1, y1, x2, y2, control_x, control_y, color) {
    strokeWeight(2);
    noFill();
    stroke.apply(null, color);
    bezier(x1, y1, control_x, control_y, control_x, control_y, x2, y2);
    this.draw_arrow_head(control_x, control_y, x2, y2, color);
  }

  draw_label(label, x, y) {
    textAlign(CENTER, CENTER);
    fill(0);
    stroke.apply(null, color_code.white);
    strokeWeight(5);
    textSize(text_size);

    text(label, x, y);
  }

  draw_edge(edge) {
    if (edge.weight == 0)
      return;

    drawingContext.setLineDash(edge.dashed ? [5] : []);

    const [n1, n2] = [this.V.get(edge.from), this.V.get(edge.to)];
    const [x1, y1] = [n1.x, n1.y];
    const [x2, y2] = [n2.x, n2.y];
    const [mx, my] = [(x1+x2)/2, (y1+y2)/2];

    const r = this.V.node_r * 1.4;
    const [px, py] = calc_edge_point(x1, y1, x2, y2, x1, y1, r);
    const [qx, qy] = calc_edge_point(x2, y2, x1, y1, x2, y2, r);

    const inv_e = this.get(edge.to, edge.from);
    if (this.directed && inv_e) {
      const vec = [x2-x1, y2-y1];
      const dist = Math.sqrt(vec[0]*vec[0] + vec[1]*vec[1]);
      const n_vec = [vec[0]/dist, vec[1]/dist];
      const dv = [-n_vec[1]*r, n_vec[0]*r];
      const [rx, ry] = [ mx+dv[0], my+dv[1] ];
      
      const [px2, py2] = [ px+0.25*dv[0], py+0.25*dv[1] ];
      const [qx2, qy2] = [ qx+0.25*dv[0], qy+0.25*dv[1] ];
      this.draw_curve_arrow(px2, py2, qx2, qy2, rx, ry, edge.color);
      this.draw_label(edge.weight, rx, ry);
    } else {
      this.draw_arrow(px, py, qx, qy, edge.color);
      this.draw_label(edge.weight, mx, my);
    }
  }

  get0(from, to) {
    if (typeof from == 'number')
      return this.get_edges().find(e => e.from == from && e.to == to);
    return this.get_edges().find(e => this.V.get(e.from) == from && this.V.get(e.to) == to);
  }

  get(from, to) {
    if (this.directed) {
      return this.get0(from, to);
    } else {
      const u = this.get0(from, to);
      return u ? u : this.get0(to, from);
    }
  }

  get_edges() {
    return this.edges.filter(e => e.weight != 0);
  }

  draw() {
    this.edges.forEach(this.draw_edge, this);
  }

  make(from_label, to_label, w) {
    return {
      from: this.V.get_index(from_label),
      to: this.V.get_index(to_label),
      weight: w,
      color: color_code.black,
      dashed: false
    }
  }

  add(...args) {
    const e = this.make.apply(this, args);
    this.edges.push(e);
  }

  modify(u, v, new_e) {
    const check = (idx, target) => this.V.get(idx) == target;
    this.edges = this.edges.map(e =>
      check(e.from, u) && check(e.to, v) ? new_e : e
    );
  }

  get_html(i, j) {
    if (i == j) {
      return '<td>0</td>';
    } else if (this.directed || i < j) {
      const e = this.get(i, j);
      return '<td><input class="alg-input" type="number" onchange="matrix_change(' + String(i) + ',' + String(j) + ',this.value)" type="text" value="' + String(e ? e.weight : 0) + '"></td>';
    } else {
      const inv_e = this.get(j, i);
      return '<td>' + String(inv_e ? inv_e.weight : 0) + '</td>';
    }
  }
}

export class Graph {
  static normal_mode = 0;
  static add_mode = 1;
  static edit_mode = 2;

  constructor(directed=true) {
    this.V = new V();
    this.E = new E(this.V, directed);
    this.mode = Graph.normal_mode;
    this.edit_mode = null;
  }

  graph_reset() {
    this.V.nodes = [];
    this.E.edges = [];
  }

  matrix_change(i, j, val) {
    const [u, v] = [this.V.get(i), this.V.get(j)];
    const e = this.E.get(i, j);
    const w = parseInt(val);
    if (e) {
      const new_e = this.E.make(u.label, v.label, w)
      this.E.modify(u, v, new_e);
    } else {
      this.E.add(u.label, v.label, w);
    }
    this.refresh();
  }

  matrix_refresh() {
    $('#matrix_tbl').empty().append($('<thead>'), $('<tbody>'));
    $('#matrix_tbl thead').append([
      '<tr>',
      '<td class="gray"></td>',
      this.V.get_labels().map(x => '<td class="gray text-center">' + x + '</td>').join(""),
      '</tr>'
    ].join(''));
    for (let i = 0; i < this.V.get_size(); i++) {
      const u = this.V.get(i);
      $('#matrix_tbl tbody').append([
        '<tr>',
        '<td class="gray">' + u.label + '</td>',
        Array.from(Array(this.V.get_size())).map(function (_, j) {
          return this.E.get_html(i, j);
        }.bind(this)).join(''),
        '</tr>'
      ].join(''))
    }
    // this.debug_output();
  }

  debug_output() {
    console.log('----');
    const v_logs = [];
    const e_logs = [];
    for (const v of this.V.get_nodes()) {
      v_logs.push('[' + ['"' + v.label + '"', parseInt(v.x), parseInt(v.y)].join(', ') + ']');
    }
    for (const e of this.E.get_edges()) {
      const u = this.V.get(e.from);
      const v = this.V.get(e.to);
      e_logs.push('[' + [
        '"' + u.label + '"',
        '"' + v.label + '"',
        e.weight].join(', ') + ']');
    }
    console.log(v_logs.join(',\n'))
    console.log(e_logs.join(',\n'))
  }

  refresh() {
    this.matrix_refresh();
    redraw();
  }

  change_mode(mode=Graph.add_mode) {
    if (mode == Graph.add_mode && $('#node_label').val() == '') {
      alert("エラー: 頂点名が空です");
    } else {
      this.mode = mode;
      this.refresh();
    }
  }

  draw() {
    background(this.mode == Graph.add_mode || this.mode == Graph.edit_mode ? color_code.gray : color_code.light_gray);
    this.V.draw();
    this.E.draw();
    if (this.mode == Graph.add_mode || this.mode == Graph.edit_mode) {
      strokeWeight(2);
      stroke.apply(null, color_code.black);
      drawingContext.setLineDash([10, 10]);
      line(mouseX, 0, mouseX, canvas_h);
      line(0, mouseY, canvas_w, mouseY);
      const label = this.mode == Graph.add_mode
                  ? $('#node_label').val()
                  : this.editing_node.label;
      this.V.draw_node(this.V.make(label, mouseX, mouseY, color_code.orange));
    }
  }

  setup() {
    const canvas = createCanvas(canvas_w, canvas_h);
    canvas.parent('canvas-hole');
    noLoop();
  }

  mouseMoved() {
    if (this.mode == Graph.add_mode || this.mode == Graph.edit_mode)
      redraw();
  }

  mouseReleased() {
    if (this.mode == Graph.add_mode) {
      const label = $('#node_label').val();
      this.V.add(label, mouseX, mouseY);
      $('#node_label').val('');
      this.change_mode(Graph.normal_mode);
    } else if (this.mode == Graph.edit_mode) {
      this.editing_node.x = mouseX;
      this.editing_node.y = mouseY;
      this.editing_node = null;
      this.change_mode(Graph.normal_mode);
    } else {
      const v = this.V.get_node_from_canvas(mouseX, mouseY);
      if (v) {
        this.editing_node = v;
        this.change_mode(Graph.edit_mode);
      }
    }
  }
}

export class DirectedGraph extends Graph {
  constructor() {
    super(true);
  }

  load_sample(id) {
    this.graph_reset();
    if (id == 1) {
      [
        ["A", 97, 393],
        ["B", 258, 251],
        ["C", 334, 493],
        ["D", 615, 254],
        ["E", 521, 472],
        ["F", 802, 403]
      ].map((v) => this.V.add.apply(this.V, v));
      [
        ["A", "B", 3],
        ["A", "C", 5],
        ["B", "C", 4],
        ["B", "D", 13],
        ["C", "E", 4],
        ["C", "D", 9],
        ["D", "F", 2],
        ["E", "D", 7],
        ["E", "F", 8]
      ].map((v) => this.E.add.apply(this.E, v));
    } else if (id == 2) {
      [
        ["A", 110, 340],
        ["B", 240, 180],
        ["C", 240, 490],
        ["D", 480, 180],
        ["E", 480, 340],
        ["F", 480, 490],
        ["G", 710, 180],
        ["H", 710, 490],
        ["I", 880, 340]
      ].map((v) => this.V.add.apply(this.V, v));
      [
        ["A", "B", 4],
        ["A", "C", 8],
        ["B", "C", 11],
        ["B", "D", 8],
        ["C", "E", 7],
        ["D", "E", 2],
        ["D", "H", 4],
        ["D", "G", 7],
        ["E", "F", 6],
        ["C", "F", 1],
        ["F", "H", 2],
        ["G", "H", 14],
        ["G", "I", 9],
        ["H", "I", 10]
      ].map((v) => this.E.add.apply(this.E, v));
    }
    this.refresh();
  }

  graph_select() {
    const id = parseInt($('#graph-select').val());
    this.load_sample(id);
  }
}

export class UndirectedGraph extends Graph {
  constructor() {
    super(false);
  }

  is_connected() {
    const g = this;
    const visitted = new Set();
    function dfs(i) {
      visitted.add(i);
      for (let j = 0; j < g.V.get_size(); j++)
        if (!visitted.has(j) && g.E.get(i, j))
          dfs(j);
    }
    dfs(0);
    return this.V.get_size() == visitted.size;
  }

  load_sample(id) {
    this.graph_reset();
    if (id == 1) {
      [
        ["0", 669, 458],
        ["1", 309, 508],
        ["2", 464, 227],
        ["3", 512, 508],
        ["4", 162, 361],
        ["5", 829, 338],
        ["6", 361, 387],
        ["7", 536, 388]
      ].map((v) => this.V.add.apply(this.V, v));
      [
        ["0", "3", 5],
        ["0", "5", 6],
        ["0", "7", 3],
        ["1", "3", 8],
        ["1", "6", 3],
        ["1", "4", 4],
        ["2", "4", 9],
        ["2", "5", 10],
        ["2", "7", 5],
        ["3", "7", 6],
        ["4", "6", 2],
        ["6", "7", 7]
      ].map((v) => this.E.add.apply(this.E, v));
    } else if (id == 2) {
      [
        ["A", 110, 340],
        ["B", 240, 180],
        ["C", 240, 490],
        ["D", 480, 180],
        ["E", 480, 340],
        ["F", 480, 490],
        ["G", 710, 180],
        ["H", 710, 490],
        ["I", 880, 340]
      ].map((v) => this.V.add.apply(this.V, v));
      [
        ["A", "B", 4],
        ["A", "C", 8],
        ["B", "C", 11],
        ["B", "D", 8],
        ["C", "E", 7],
        ["D", "E", 2],
        ["D", "H", 4],
        ["D", "G", 7],
        ["E", "F", 6],
        ["C", "F", 1],
        ["F", "H", 2],
        ["G", "H", 14],
        ["G", "I", 9],
        ["H", "I", 10]
      ].map((v) => this.E.add.apply(this.E, v));
    }
    this.refresh();
  }

  graph_select() {
    const id = parseInt($('#graph-select').val());
    this.load_sample(id);
  }
}

