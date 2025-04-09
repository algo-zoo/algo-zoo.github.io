let drawQueue = (queue: array<string>) => {
  StackVis.drawLabel("Queue", 1, 0)
  QueueVis.drawQueue(queue, 9, ~offsetI=1, ~offsetJ=1)
}

%%raw(`
import { blue, red, white, yellow} from './ColorCode.js'
import { DirectedGraph } from './Graph.js'

class BFS extends DirectedGraph {
  constructor() {
    super()
    this.S = new Set();
    this.queue = [];
  }

  next_node() {
    if (this.queue.length == 0)
      return null;
    const u = this.queue.shift();
    return !this.S.has(u) ? u : this.next_node();
  }

  onestep(call_refresh=true) {
    if (this.queue.size == 0)
      return;
    const u = this.next_node();
    if (u == null)
      return;
    u.order = this.S.size;
    this.S.add(u);
    for (const edge of this.E.get_edges()) {
      if (edge.weight == 0)
        continue;

      const f = this.V.get(edge.from);
      if (f == u) {
        const t = this.V.get(edge.to);
        if (!this.S.has(t) && !this.queue.includes(t))
          this.queue.push(t);
      }
    }
    if (call_refresh)
      this.refresh();
  }

  bfs() {
    while (this.queue.length > 0)
      this.onestep(false);
    this.refresh();
  }

  initialize() {
    this.S.clear();
    this.V.nodes.forEach(function (node) {
      node.order = null;
    });

    const val = $('#start').val();
    const start_idx = val ? val : 0;
    const s = this.V.get(start_idx);
    this.queue = [];
    if (s) {
      this.queue.push(s);
    }
  }

  setup() {
    super.setup();
    this.reset();
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

  set_color() {
    this.V.nodes.forEach(function (node) {
      if (this.S.has(node))
        node.color = red;
      else if (this.queue.includes(node))
        node.color = yellow;
      else if (node == this.V.get($('#start').val()))
        node.color = blue;
      else
        node.color = white;
    }.bind(this));
  }

  draw_search_order() {
    for (const u of this.V.get_nodes()) {
      if (this.S.has(u)) {
        fill.apply(null, red);
        text(u.order, u.x, u.y-2*this.V.node_r);
      }
    }
  }

  draw() {
    this.set_color();
    super.draw();
    this.draw_search_order();
    drawQueue(this.queue.map(v => v.label));
  }

  refresh() {
    this.start_node_refresh();
    super.refresh();
  }

  reset() {
    this.initialize();
    this.refresh();
  }

  graph_select() {
    super.graph_select();
    this.reset();
  }
}

const graph = new BFS();
window.setup = graph.setup.bind(graph);
window.draw = graph.draw.bind(graph);
window.mouseMoved = graph.mouseMoved.bind(graph);
window.mouseReleased = graph.mouseReleased.bind(graph);
window.matrix_change = graph.matrix_change.bind(graph);

$(document).ready(function() {
  $('#add').click(() => graph.change_mode());
  $('#search').click(() => graph.onestep());
  $('#goal').click(() => graph.bfs());
  $('#reset').click(() => graph.reset());
  $('#start').change(() => graph.reset());
  $('#graph-select').change(() => graph.graph_select());
});
`)
