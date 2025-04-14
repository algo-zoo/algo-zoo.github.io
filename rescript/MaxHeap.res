%%raw(`
import { Heap } from './Heap.js'

class MaxHeap extends Heap {
  compare(x, y) {
    return x < y;
  }
}

const heap = new MaxHeap();
window.setup = heap.setup.bind(heap);
window.draw = heap.draw.bind(heap);

$(document).ready(function() {
  $('#run').click(() => heap.setup());
  $('#prev').click(() => heap.prev());
  $('#next').click(() => heap.next());
  $('#program').on('input', () => heap.reset());
 
  $('#program').val([
    'insert(42)',
    'insert(2)',
    'insert(5)',
    'insert(58)',
    'insert(27)',
    'insert(34)',
    'insert(1)',
    'insert(8)',
    'delete()',
    'insert(39)',
    'insert(55)',
  ].join("\n"));
  $('#program').height($('#program')[0].scrollHeight);
});
`)
