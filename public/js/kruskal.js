import { color_code } from './color-code.js'
import { UnionFind } from './UnionFind.js'
import { UndirectedGraph } from './graph.js'

class Kruskal extends UndirectedGraph {
  onestep(call_refresh=true) {
    if (!this.is_connected()) {
      alert('Error: The graph is not a connected graph.');
      return;
    }

    if (this.queue.length == 0)
      return;
    const e = this.queue.shift();
    if (UnionFind.isSame(this.uf, e.from, e.to)) {
      e.dashed = true;
    } else {
      this.mst.push(e);
      UnionFind.unite(this.uf, e.from, e.to);
      e.color = color_code.red;
    }
    if (call_refresh)
      this.refresh();
  }

  kruskal() {
    while (this.queue.length > 0)
      this.onestep(false);
    this.refresh();
  }

  initialize() {
    for (const e of this.E.get_edges()) {
      e.dashed = false;
      e.color = color_code.black;
    }

    this.queue = this.E.get_edges().sort((e, f) => e.weight - f.weight);
    this.uf = UnionFind.create(this.queue.length);
    this.mst = [];
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
    if ($('#data_tbl tbody').length == 0) {
      $('#data_tbl').append($('<tbody>'));
    }
    const to_label = function(e) {
      if (e.dashed)
        return '不採用';
      else if (e.color == color_code.red)
        return '採用'; 
      return '';
    }
    for (const e of this.E.get_edges()) {
      const label = '(' + e.from.toString() + ', ' + e.to.toString() + ')';
      $('#data_tbl tbody').append('<tr>' +
        '<td>' + label + '</td>' +
        '<td>' + e.weight.toString() + '</td>' +
        '<td>' + to_label(e) + '</td>' +
        '</tr>');
    }
  }

  matrix_change(i, j, val) {
    super.matrix_change(i, j, val);
    this.reset();
  }

  refresh() {
    this.table_refresh();
    super.refresh();
  }

  graph_select() {
    super.graph_select();
    this.reset();
  }
}

const graph = new Kruskal();
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
  $('#goal').click(() => graph.kruskal());
  $('#reset').click(() => graph.reset());
  $('#graph-select').change(() => graph.graph_select());
});
