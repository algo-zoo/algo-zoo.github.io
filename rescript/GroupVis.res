%%raw(`
import { black, gray, lightGray, red, white, yellow } from './ColorCode.js'
import { calc_dist, calc_edge_point } from './DrawUtil.js'

const text_size = 24;
const canvas_w = 1000;
const canvas_h = 1000;

class V {
  constructor() {
    this.node_r = 25;
    this.nodes = [];

    [
      ["0", 669, 458],
      ["1", 309, 508],
      ["2", 464, 227],
      ["3", 512, 508],
      ["4", 162, 361],
      ["5", 829, 338],
      ["6", 361, 387],
      ["7", 536, 388]
    ].forEach(args => this.add.apply(this, args));
  }

  draw_node(node) {
    const node_d = this.node_r * 2;
    strokeWeight(2);
    stroke.apply(null, black);
    fill.apply(null, node.color);
    ellipse(node.x, node.y, node_d, node_d);

    textAlign(CENTER, CENTER);
    fill(0);
    textSize(text_size);
    text(node.label, node.x, node.y);
  }

  make(label, x, y, color=white) {
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
  constructor(V) {
    this.V = V;
    this.edges = [];

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
    ].forEach(args => this.add.apply(this, args));
  }

  draw_edge(edge) {
    if (edge.weight == 0)
      return;

    const [n1, n2] = [this.V.get(edge.from), this.V.get(edge.to)];
    const [x1, y1] = [n1.x, n1.y];
    const [x2, y2] = [n2.x, n2.y];
    const r = this.V.node_r * 1.4;
    const [px, py] = calc_edge_point(x1, y1, x2, y2, x1, y1, r);
    const [qx, qy] = calc_edge_point(x2, y2, x1, y1, x2, y2, r);
    strokeWeight(2);
    fill.apply(null, edge.color);
    stroke.apply(null, edge.color);
    line(px, py, qx, qy);

    const [lx, ly] = [(x1+x2)/2, (y1+y2)/2];
    textAlign(CENTER, CENTER);
    fill(0);
    stroke(255, 255, 255);
    strokeWeight(5);
    textSize(text_size);
    text(edge.weight, lx, ly);
  }

  get(from, to) {
    return this.edges.find(e => e.from == from && e.to == to);
  }

  draw() {
    this.edges.forEach(this.draw_edge, this);
  }

  make(from_label, to_label, w) {
    return {
      from: this.V.get_index(from_label),
      to: this.V.get_index(to_label),
      weight: w,
      color: black
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
}

class Graph {
  static normal_mode = 0;
  static add_mode = 1;
  static edit_mode = 2;

  constructor() {
    this.V = new V();
    this.E = new E(this.V);
    this.mode = Graph.normal_mode;
    this.edit_mode = null;

    this.group_nodes = [ 0, 2, 3, 7 ];
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
    $('#matrix_tbl thead').empty();
    $('#matrix_tbl tbody').empty();
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
          const v = this.V.get(j);
          const e = this.E.get(i, j);
          if (i == j) {
            return '<td>0</td>';
          } else if (i < j) {
            return '<td><input class="alg-input" type="number" onchange="matrix_change(' + String(i) + ',' + String(j) + ',this.value)" type="text" value="' + String(e ? e.weight : 0) + '"></td>';
          } else {
            const inv_e = this.E.get(j, i);
            return '<td>' + String(inv_e ? inv_e.weight : 0) + '</td>';
          }
        }.bind(this)).join(''),
        '</tr>'
      ].join(''))
    }
  }

  refresh() {
    this.matrix_refresh();
    redraw();
  }

  change_mode(mode) {
    this.mode = mode;
    this.refresh();
  }

  draw() {
    background(this.mode == Graph.add_mode || this.mode == Graph.edit_mode ? gray : lightGray);
    this.V.draw();
    this.E.draw();
    if (this.mode == Graph.add_mode || this.mode == Graph.edit_mode) {
      strokeWeight(2);
      stroke.apply(null, black);
      line(mouseX, 0, mouseX, canvas_h);
      line(0, mouseY, canvas_w, mouseY);
      const label = this.mode == Graph.add_mode
                  ? $('#node_label').val()
                  : this.editing_node.label;
      this.V.draw_node(this.V.make(label, mouseX, mouseY, red));
    }

    const r = this.V.node_r * 1.4;
    const sampling_size = 24;
    const dt = 2 * Math.PI / sampling_size;

    const points = []
    for (const v of this.group_nodes.map(idx => this.V.get(idx))) {
      for (let i = 0; i < sampling_size; i++) {
        const theta = i * dt;
        const px = v.x + Math.cos(theta) * r;
        const py = v.y + Math.sin(theta) * r;
        points.push([ px, py ]);
      }
    }

    const segment_sampling_size = sampling_size * 2;
    for (const i of this.group_nodes) {
      for (const j of this.group_nodes) {
        const e = this.E.get(i, j);
        if (e) {
          const [u, v] = [this.V.get(i), this.V.get(j)];

          const vec = [u.x - v.x, u.y - v.y];
          const dist = Math.sqrt(vec[0]*vec[0] + vec[1]*vec[1]);
          const n_vec = [vec[0]/dist, vec[1]/dist];

          const dv1 = [-n_vec[1]*r, n_vec[0]*r];
          const dv2 = [n_vec[1]*r, -n_vec[0]*r];
          for (let k = 0; k < segment_sampling_size; k++) {
            const tx = (u.x*k + v.x*(segment_sampling_size-k))/segment_sampling_size;
            const ty = (u.y*k + v.y*(segment_sampling_size-k))/segment_sampling_size;
            points.push([ tx+dv1[0], ty+dv1[1] ]);
            points.push([ tx+dv2[0], ty+dv2[1] ]);
          }
        }
      }
    }

    // stroke.apply(null, yellow);
    // strokeWeight(4);
    // for (const [x, y] of points) {
    //   circle(x, y, 2);
    // }

    const hull_points = hull(points);
    stroke.apply(null, red);
    for (let i = 0; i < hull_points.length; i++) {
      const [px, py] = hull_points[i];
      const [qx, qy] = hull_points[(i+1)%hull_points.length];
      line(px, py, qx, qy);
    }
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
      const v = this.V.make(this.editing_node.label, mouseX, mouseY);
      this.V.modify(this.editing_node, v);
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

window.setup = function() {
  const canvas = createCanvas(canvas_w, canvas_h);
  canvas.parent('canvas-hole');
  noLoop();
}

const graph = new Graph();

window.matrix_change = graph.matrix_change.bind(graph);
window.draw = graph.draw.bind(graph);
window.mouseMoved = graph.mouseMoved.bind(graph);
window.mouseReleased = graph.mouseReleased.bind(graph);

$(document).ready(function() {
  $('#add').click(() => graph.change_mode(Graph.add_mode));
  graph.refresh();
});
`)
