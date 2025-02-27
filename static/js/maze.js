import { dark, white, red, light_gray } from './ColorCode.js'

var cv = { // constant values
  w: -1,
  h: -1,
  box_size: 100,
  label_size: 20,
  text_size: 36,
  INF: 10**10
}
const state = {
  maze: [],
  dist: null,
  current_depth: -1,
  max_depth: -1
}

const load_sample = function(id) {
  if (id == 1) {
    $('#maze-input').val([
      '.#....#G',
      '.#.#....',
      '...#.##.',
      '#.##...#',
      '...###.#',
      '.#.....#',
      '...#.#..',
      'S.......'
    ].join("\n"));
  } else if (id == 2) {
    $('#maze-input').val([
      '..#...#G',
      '..#.#...',
      '.....##.',
      'S..#....',
    ].join("\n"));
  } else {
    $('#maze-input').val('');
  }
}

const initializeMaze = function() {
  const id = parseInt($('#maze-select').val());
  load_sample(id);
}

const getPosition = function(c) {
  for (let i = 0; i < state.maze.length; i++)
    for (let j = 0; j < state.maze[i].length; j++)
      if (state.maze[i][j] == c)
        return [i, j];
  return null;
}

const setMaze = function() {
  state.maze = $('#maze-input').val().split('\n');
  if (state.maze[0] != '') {
    cv.w = cv.box_size * (state.maze[0].length + 1);
    cv.h = cv.box_size * (state.maze.length + 1);
  }
  createCanvas(cv.w, cv.h).parent('canvas-hole');
  bfs();
  state.current_depth = 0;
}

window.setup = function() {
  createCanvas(0, 0).parent('canvas-hole');
  noLoop();
}

const bfs = function() {
  const s = getPosition('S');
  const g = getPosition('G');
  if (!s) {
    alert('Error: The start position (\'S\') is not defined.')
    return;
  }
  if (!g) {
    alert('Error: The goal position (\'G\') is not defined.')
    return;
  }

  const [sy, sx] = s;
  const [gy, gx] = g;

  const w = state.maze[0].length;
  const h = state.maze.length;
  state.dist = Array.from({ length: h }, () => Array(w).fill(cv.INF));

  let queue = [];
  queue.push([sy, sx]);
  state.dist[sy][sx] = 0;
  while (queue.length > 0 && state.dist[gy][gx] == cv.INF) {
    const [i, j] = queue.shift();
    for (const [di, dj] of [ [0, 1], [1, 0], [0, -1], [-1, 0] ]) {
      const ni = i + di;
      const nj = j + dj;
      if (!(0 <= ni && ni < h) || !(0 <= nj && nj < w))
        continue;
      if (state.maze[ni][nj] == '#')
        continue;
      const new_dist = state.dist[i][j] + 1;
      if (state.dist[ni][nj] > new_dist) {
        state.dist[ni][nj] = new_dist;
        queue.push([ni, nj]);
      }
    }
  }
  state.max_depth = max(state.dist.flatMap(x => x).filter(x => x != cv.INF));
}

const drawBox = function(i, j) {
  const offset = cv.box_size / 2;
  const x = offset + cv.box_size * j;
  const y = offset + cv.box_size * i;
  fill(state.maze[i][j] == '#' ? dark : white);
  rect(x, y, cv.box_size, cv.box_size);
}

const drawHeader = function(i, j) {
  const offset = cv.box_size / 2;
  const padding = cv.box_size * 0.05;
  const x = offset + padding + cv.box_size * j;
  const y = offset + padding + cv.label_size + cv.box_size * i;
  

  const header = '(' + j + ', ' + i + ')';
  fill(red);
  textSize(cv.label_size);
  textAlign(LEFT, BASELINE);
  text(header, x, y);
  if (state.maze[i][j] == 'S' || state.maze[i][j] == 'G') {
    const x2 = offset - padding + cv.box_size * (j+1);
    textAlign(RIGHT, BASELINE);
    text('[' + state.maze[i][j] + ']', x2, y);
  }
}

const drawDistance = function(i, j) {
  const d = state.dist[i][j];
  if (d != cv.INF && d <= state.current_depth) {
    const offset = cv.box_size / 2;
    const x = offset + cv.box_size * (j + 0.5);
    const y = offset + cv.box_size * (i + 0.5);
    
    fill(0);
    textSize(cv.text_size);
    textAlign(CENTER, CENTER);
    text(state.dist[i][j], x, y);
  }
}

const drawMaze = function() {
  const offset = cv.box_size / 2;
  for (let i = 0; i < state.maze.length; i++) {
    for (let j = 0; j < state.maze[i].length; j++) {
      drawBox(i, j);
      drawHeader(i, j);
      drawDistance(i, j);
    }
  }
}

window.draw = function() {
  $('#prev').prop('disabled', state.current_depth == -1 || state.current_depth == 0);
  $('#next').prop('disabled', state.current_depth == -1 || state.current_depth == state.max_depth);
  background(light_gray);
  drawMaze();
}

$(document).ready(function() {
  $('#maze-load').click(function() {
    setMaze();
    draw();
  });
  $('#prev').click(function() {
    if (state.current_depth > 0) {
      state.current_depth--;
      draw();
    }
  });
  $('#next').click(function() {
    if (state.current_depth < state.max_depth) {
      state.current_depth++;
      draw();
    }
  });
  $('#maze-select').change(initializeMaze);
});

