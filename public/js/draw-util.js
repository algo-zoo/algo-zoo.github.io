const epsilon = 0.00001;

export const calc_dist = function(x1, y1, x2, y2) {
  return Math.sqrt((x1-x2)**2 + (y1-y2)**2);
}

export const calc_edge_point = function(x1, y1, x2, y2, px, py, r) {
  if (x1 == x2)
    x1 += epsilon;
  const d = (y2 - y1) / (x2 - x1);
  const f = r / Math.sqrt(1 + d*d);
  const [qx, qy] = [x1 + f, y1 + d * f];
  const [rx, ry] = [x1 - f, y1 - d * f];
  const [mx, my] = [(x1+x2)/2, (y1+y2)/2];
  if (calc_dist(qx, qy, mx, my) < calc_dist(rx, ry, mx, my)) {
    return [qx, qy];
  } else {
    return [rx, ry];
  }
}

export const rotation = function(cx, cy, x, y, theta) {
  const tx = (x - cx) * Math.cos(theta) - (y - cy) * Math.sin(theta) + cx;
  const ty = (x - cx) * Math.sin(theta) + (y - cy) * Math.cos(theta) + cy;
  return [tx, ty];
}

export const draw_arrow = function(x1, y1, x2, y2) {
  line(x1, y1, x2, y2);
  const [ax, ay] = calc_edge_point(x2, y2, x1, y1, x2, y2, 10);
  const [bx, by] = rotation(x2, y2, ax, ay, Math.PI / 8);
  const [cx, cy] = rotation(x2, y2, ax, ay, -Math.PI / 8);
  triangle(x2, y2, bx, by, cx, cy);
}
