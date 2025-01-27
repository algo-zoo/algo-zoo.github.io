import { UndirectedGraph } from './graph.js'

const graph = new UndirectedGraph();
window.setup = graph.setup.bind(graph);
window.draw = graph.draw.bind(graph);
window.mouseMoved = graph.mouseMoved.bind(graph);
window.mouseReleased = graph.mouseReleased.bind(graph);
window.matrix_change = graph.matrix_change.bind(graph);

$(document).ready(function() {
  $('#add').click(() => graph.change_mode());
  $('#graph-select').change(() => graph.graph_select());
});
