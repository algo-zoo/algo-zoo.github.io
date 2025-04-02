let convex_hull = ConvexHull.hull

%%raw(`
import { red, white } from './ColorCode.js'

// ==== constant value ====
const cv = {
  w: 1000,
  h: 1000,
  node_r: 15,
}

const text_size = 24;
// ========

const state = {
  points: null,
  hull: null,
  depth: null
}

function initialize() {
  state.points = [];
  state.hull = [];
  state.depth = 0;
}

window.setup = function() {
  const canvas = createCanvas(cv.w, cv.h);
  canvas.parent('canvas-hole');
  // textSize(text_size);
  // noLoop();
}

window.draw = function() {
  background(200);
  for (const [x, y] of state.points) {
    fill.apply(null, white);
    circle(x, y, cv.node_r);
  }
  const len = min(state.depth, state.hull.length);
  for (let i = 0; i < len; i++) {
    const [px, py] = state.hull[i];
    const [qx, qy] = state.hull[(i+1)%len];
    line(px, py, qx, qy);
  }
  for (let i = 0; i < len; i++) {
    fill.apply(null, red);
    const [x, y] = state.hull[i];
    circle(x, y, cv.node_r);
  }
}


function mouseReleased() {
  const pt = [ parseInt(mouseX), parseInt(mouseY) ];
  const [x, y] = pt;
  if (0 <= x && x < cv.w && 0 <= y && y < cv.h) {
    state.points.push(pt);
    run();
  }
}

function run() {
  state.hull = convex_hull(state.points);
  state.depth = 0;
}

function prev_btn() {
  if (state.depth > 0) {
    state.depth--;
  }
}

function next_btn() {
  if (state.depth < state.hull.length) {
    state.depth++;
  }
}

function random_btn() {
  initialize();
  const offset = 100;
  for (let i = 0; i < 50; i++) {
    const x = offset + Math.floor(Math.random() * (cv.w - 2*offset));
    const y = offset + Math.floor(Math.random() * (cv.h - 2*offset));
    state.points.push([ x, y ]);
  }
  run();
}

function reset_btn() {
  initialize();
}

$(document).ready(function() {
  $('#random').click(random_btn);
  $('#reset').click(reset_btn);
  $('#prev').click(prev_btn);
  $('#next').click(next_btn);
  initialize();
});
`)
