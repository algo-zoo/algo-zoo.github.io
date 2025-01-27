export function convex_hull(points) {
  const cross = function (v1, v2) {
    return v1[0] * v2[1] - v1[1] * v2[0];
  }

  const ccw = function (p, q, r) {
    const pq = [ q[0] - p[0], q[1] - p[1] ];
    const qr = [ r[0] - q[0], r[1] - q[1] ];
    return cross(pq, qr) > 0;
  }
  
  const calc_next = function (current_idx) {
    var next_idx = (current_idx+1) % points.length;
    for (let i = 0; i < points.length; i++)
      if (ccw(points[current_idx], points[i], points[next_idx]))
        next_idx = i;
    return next_idx;
  }

  if (points.length <= 2)
    return [];

  points.sort(function (pt1, pt2) {
    const [x1, y1] = pt1;
    const [x2, y2] = pt2;
    return x1 == x2 ? y1 - y2 : x1 - x2;
  });

  const hull = [];
  const start_idx = 0;
  var current_idx = start_idx;
  do {
    hull.push(points[current_idx]);
    current_idx = calc_next(current_idx);
  } while (current_idx != start_idx);

  return hull;
}

