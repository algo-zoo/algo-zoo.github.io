import { color_code } from './color-code.js'
import { DirectedGraph } from './graph.js'

class Dijkstra extends DirectedGraph {
  constructor() {
    super();
    this.S = new Set();
    this.path_mode = false;
  }

  onestep(call_refresh=true) {
    if (this.S.size >= this.V.get_size())
      return;

    const u = this.V.get_nodes()
                    .filter((v) => !this.S.has(v))
                    .reduce((acc, val) => acc.dist < val.dist ? acc : val);
    for (const edge of this.E.get_edges()) {
      const f = this.V.get(edge.from);
      if (f == u) {
        const t = this.V.get(edge.to);
        const w = edge.weight;
        if (w == 0)
          continue;
        const u2t_w = u.dist + w;
        if (t.dist > u2t_w) {
          t.dist = u2t_w;
          t.prev = u;
        }
      }
    }
    this.S.add(u);
    if (call_refresh)
      this.refresh();
  }

  dijkstra() {
    while (this.S.size < this.V.get_size())
      this.onestep(false);
    this.refresh();
  }

  initialize() {
    this.S.clear();
    this.V.nodes.forEach(function (node) {
      node.dist = Infinity;
      node.prev = null;
      node.color = color_code.white;
    });
    this.E.edges.forEach(function (edge) {
      edge.color = color_code.black;
    });

    if (this.V.get_size() > 0) {
      const val = $('#start').val();
      const start_idx = val ? val : 0;
      this.V.nodes[start_idx].dist = 0;
    }
  }

  setup() {
    super.setup();
    this.reset();
  }

  reset() {
    this.initialize();
    this.refresh();
  }

  table_refresh() {
    $('#data_tbl td').parent().empty();
    for (let i = 0; i < this.V.get_size(); i++) {
      const node = this.V.get(i);
      const dist = "dist[" + node.label + "] = " + (node.dist==Infinity?"∞":node.dist);
      const prev = "prev[" + node.label + "] = " + (node.prev?node.prev.label:"NULL");
  
      $('#data_tbl tbody').append('<tr>' +
                       '<td>' + node.label + '</td>' +
                       '<td>' + (this.S.has(node) ? "確定" : "未確定") + '</td>' +
                       '<td>' + dist + '</td>' +
                       '<td>' + prev + '</td>' +
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

  matrix_change(i, j, val) {
    super.matrix_change(i, j, val);
    this.reset();
  }

  refresh() {
    this.table_refresh();
    this.start_node_refresh();
    super.refresh();
  }

  set_color() {
    this.V.nodes.forEach(function (node) {
      if (this.S.has(node))
        node.color = color_code.red;
      else if (node == this.V.get($('#start').val()))
        node.color = color_code.blue;
      else
        node.color = color_code.white;
    }.bind(this));
    this.E.edges.forEach(function (edge) {
      edge.color = this.S.has(this.V.get(edge.from)) ? color_code.red : color_code.black;
    }.bind(this));
  
    if (this.path_mode) {
      var node = this.V.get_node_from_canvas(mouseX, mouseY);
      do {
        const p = node.prev;
        const e = this.E.get(p, node);
        if (e)
          e.color = color_code.yellow;
        node.color = color_code.yellow;
        node = p;
      } while (node);
    }
  }

  draw() {
    this.set_color();
    super.draw();
  }

  has_shortest_path(x, y) {
    const node = this.V.get_node_from_canvas(x, y);
    return node ? this.S.has(node) : false;
  }

  mouseMoved() {
    this.path_mode = this.has_shortest_path(mouseX, mouseY);
    super.mouseMoved();
    this.draw();
  }

  graph_select() {
    super.graph_select();
    this.reset();
  }
}

const graph = new Dijkstra();
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
  $('#goal').click(() => graph.dijkstra());
  $('#reset').click(() => graph.reset());
  $('#start').change(() => graph.reset());
  $('#graph-select').change(() => graph.graph_select());
});

