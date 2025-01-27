import { color_code } from './color-code.js'
import { UndirectedGraph } from './graph.js'

class Prim extends UndirectedGraph {
  onestep(call_refresh=true) {
    if (!this.is_connected()) {
      alert('Error: The graph is not a connected graph.');
      return;
    }

    if (this.prim_nodes.size >= this.V.get_size()) {
      this.delete_non_mst_edges();
    } else {
      const complement = this.V.nodes.filter(w => !this.prim_nodes.has(w));

      const candidates = [];
      for (const u of this.prim_nodes) {
        for (const v of complement) {
          const e = this.E.get(u, v) || this.E.get(v, u);
          if (e) {
            candidates.push(e);
          }
        }
      }
      if (candidates.length == 0)
        return;
  
      const min_e = candidates.reduce((x, y) => x.weight < y.weight ? x : y);
      const [u, v] = [this.V.get(min_e.from), this.V.get(min_e.to)];
      u.color = color_code.red;
      v.color = color_code.red;
      this.prim_nodes.add(u);
      this.prim_nodes.add(v);
      this.mst.push(min_e);
  
      min_e.color = color_code.red;
    }
    if (call_refresh)
      this.refresh();
  }

  prim() {
    while (this.prim_nodes.size < this.V.get_size())
      this.onestep(false);
    this.delete_non_mst_edges();
    this.refresh();
  }

  delete_non_mst_edges() {
    for (const e of this.E.get_edges()) {
      const [u, v] = [this.V.get(e.from), this.V.get(e.to)];
      if (!this.mst.includes(e)) {
        e.dashed = true;
      }
    }

    this.finished = true;
  }

  initialize() {
    for (const e of this.E.get_edges()) {
      e.dashed = false;
      e.color = color_code.black;
    }
    for (const v of this.V.get_nodes()) {
      v.color = color_code.white;
    }
    this.mst = [];
  
    this.prim_nodes = new Set();
    const start_idx = $('#start').val() ? $('#start').val() : 0;
    const v = this.V.get(start_idx);
    if (v) {
      v.color = color_code.red;
      this.prim_nodes.add(v);
    }

    this.finished = false;
  }

  setup() {
    super.setup();
    this.reset();
  }

  reset() {
    this.initialize();
    this.refresh();
  }

  matrix_change(i, j, val) {
    super.matrix_change(i, j, val);
    this.reset();
  }

  table_refresh() {
    $('#data_tbl td').parent().empty();
    const to_label = function(e) {
      if (e.dashed)
        return '不採用';
      else if (e.color == color_code.red)
        return '採用'; 
      return '';
    }
    for (const e of this.E.get_edges()) {
      const u = this.V.get(e.from);
      const v = this.V.get(e.to);
      const label = '(' + u.label + ', ' + v.label + ')';
      $('#data_tbl tbody').append('<tr>' +
        '<td>' + label + '</td>' +
        '<td>' + e.weight.toString() + '</td>' +
        '<td>' + to_label(e) + '</td>' +
        '</tr>');
    }
  }

  start_node_refresh() {
    if (this.V.get_size() > 0) {
      const v = $('#start').val();
      $('#start').empty();
      for (let i = 0; i < this.V.get_size(); i++) {
        const v = this.V.get(i);
        $("#start").append($("<option>").html(v.label).val(i));
      }
      $('#start').val(v ? v : 0);
    }
  }

  refresh() {
    this.table_refresh();
    this.start_node_refresh();
    super.refresh();
  }

  draw_grouping() {
    const r = this.V.node_r * 1.4;
    const sampling_size = 24;
    const dt = 2 * Math.PI / sampling_size;

    const points = []
    this.prim_nodes.forEach(function(v) {
      for (let i = 0; i < sampling_size; i++) {
        const theta = i * dt;
        const px = v.x + Math.cos(theta) * r;
        const py = v.y + Math.sin(theta) * r;
        points.push([ px, py ]);
      }
    });

    const segment_sampling_size = sampling_size * 2;
    this.prim_nodes.forEach(function(u) {
      this.prim_nodes.forEach(function(v) {
        const e = this.E.get(u, v);
        if (e) {
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
      }, this);
    }, this);

    // ==== DEBUG OUTPUT ====
    // stroke.apply(null, color_code.blue);
    // strokeWeight(4);
    // for (const [x, y] of points) {
    //   circle(x, y, 2);
    // }
    // ==== DEBUG OUTPUT ====

    const hull_points = hull(points);
    stroke.apply(null, color_code.yellow);
    for (let i = 0; i < hull_points.length; i++) {
      const [px, py] = hull_points[i];
      const [qx, qy] = hull_points[(i+1)%hull_points.length];
      line(px, py, qx, qy);
    }
  }

  draw() {
    super.draw();
    if (this.prim_nodes.size > 0 && !this.finished) {
      this.draw_grouping();
    }
  }

  graph_select() {
    super.graph_select();
    this.reset();
  }
}

const graph = new Prim();
window.setup = graph.setup.bind(graph);
window.draw = graph.draw.bind(graph);
window.mouseMoved = graph.mouseMoved.bind(graph);
window.mouseReleased = graph.mouseReleased.bind(graph);
window.matrix_change = graph.matrix_change.bind(graph);

$(document).ready(function() {
  renderMathInElement(document.body, {
      delimiters: [{left: '$', right: '$', display: false}],
      throwOnError : false
  });
  $('#add').click(() => graph.change_mode());
  $('#search').click(() => graph.onestep());
  $('#goal').click(() => graph.prim());
  $('#reset').click(() => graph.reset());
  $('#start').change(() => graph.reset());
  $('#graph-select').change(() => graph.graph_select());
});

