type fileType
type canvas
type image
type drawFunc = canvas => canvas

type point = (int, int)
type size = (int, int)

type cornerPoints = (point, point, point, point)

type stateType = {
  canvas: ref<option<canvas>>,
  cursor: ref<point>,
  corners: ref<cornerPoints>,
  editPointIndex: ref<option<int>>
}

// ==== Canvas Utility ====
let drawPoint: (canvas, point) => canvas = %raw(`
  function (canvas, pt) {
    const [x, y] = pt;
    const ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.arc(x, y, 5, 0, Math.PI * 2);
    ctx.fillStyle = "red";
    ctx.fill();
    return canvas;
  }
`)

let drawLine: (canvas, point, point) => canvas = %raw(`
  function (canvas, pt1, pt2) {
    const [x1, y1] = pt1;
    const [x2, y2] = pt2;
    const ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
    return canvas;
  }
`)

let drawRect: (canvas, point, size) => canvas = %raw(`
  function (canvas, pt, sz) {
    const [x, y] = pt;
    const [w, h] = sz;
    const ctx = canvas.getContext("2d");
    ctx.fillRect(x, y, w, h);
    return canvas;
  }
`)

let getColorCode: ColorCode.color => string = %raw(`
  function (color) {
    return "rgb(" + color[0] + "," + color[1] + "," + color[2] + ")";
  }
`)

let strokeColor: (canvas, ColorCode.color) => canvas = %raw(`
  function (canvas, color) {
    const ctx = canvas.getContext("2d");
    ctx.strokeStyle = getColorCode(color);
    return canvas;
  }
`)

let fillColor: (canvas, ColorCode.color) => canvas = %raw(`
  function (canvas, color) {
    const ctx = canvas.getContext("2d");
    ctx.fillStyle = getColorCode(color);
    return canvas;
  }
`)

let strokeWidth: (canvas, int) => canvas = %raw(`
  function (canvas, width) {
    const ctx = canvas.getContext("2d");
    ctx.lineWidth = width;
    return canvas;
  }
`)

let getSize: canvas => size = %raw(`
  function (canvas) {
    return [canvas.width, canvas.height];
  }
`)

let getRectSize: string => size = %raw(`
  function (id) {
    const canvas = $(id)[0];
    const ctx = canvas.getContext("2d");
    const rect = canvas.getBoundingClientRect();
    return [rect.width, rect.height];
  }
`)

let setCanvas: (canvas, string) => unit = %raw(`
  function (src_canv, id) {
    const tar_canv = $(id)[0];
    const tar_ctx = tar_canv.getContext("2d");
    tar_ctx.canvas.width = src_canv.width;
    tar_ctx.canvas.height = src_canv.height;
    tar_ctx.drawImage(src_canv, 0, 0);
  }
`)

let initializeCanvas: (fileType, canvas => unit) => unit = %raw(`
  function (file, cont) {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = function() {
      const data = reader.result;
      const img = new Image();
      img.src = data;
      img.onload = function () {
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        cont(canvas);
      }
    }
  }
`)

let duplicateCanvas: canvas => canvas = %raw(`
  function (canvas) {
    const newCanvas = document.createElement("canvas");
    newCanvas.width = canvas.width;
    newCanvas.height = canvas.height;
    const ctx = newCanvas.getContext("2d");
    ctx.drawImage(canvas, 0, 0);
    return newCanvas;
  }
`)
// ==== Canvas Utility ====

let state:stateType = {
  canvas: ref(None),
  cursor: ref((-1, -1)),
  corners: ref(((0, 0), (0, 0), (0, 0), (0, 0))),
  editPointIndex: ref(None)
}

let isEditMode = (state:stateType): bool => {
  switch state.editPointIndex.contents {
  | Some(_) => true
  | None => false
  }
}

let calcDist = (pt1: point, pt2: point): int => {
  let (x1, y1) = pt1
  let (x2, y2) = pt2
  let p1 = Math.pow(float_of_int(x2 - x1), ~exp=2.0)
  let p2 = Math.pow(float_of_int(y2 - y1), ~exp=2.0)
  int_of_float(Math.sqrt(p1 +. p2))
}

let transform: (canvas, cornerPoints) => canvas = %raw(`
  function (canvas, corners) {
    const ctx = canvas.getContext("2d");

    const [pt1, pt2, pt3, pt4] = corners;
    const widthTop = calcDist(pt1, pt2);
    const widthBottom = calcDist(pt3, pt4);
    const tarWidth = Math.max(widthTop, widthBottom);
  
    const heightLeft = calcDist(pt1, pt4);
    const heightRight = calcDist(pt2, pt3);
    const tarHeight = Math.max(heightLeft, heightRight);

    const fxCanvas = fx.canvas();
    const texture = fxCanvas.texture(canvas);
    fxCanvas.draw(texture)
      .perspective(
        [...pt1, ...pt2, ...pt3, ...pt4],
        [0, 0, tarWidth, 0, tarWidth, tarHeight, 0, tarHeight]
      )
      .update();
    canvas.width = tarWidth;
    canvas.height = tarHeight;
    ctx.drawImage(fxCanvas, 0, 0);
    
    return canvas;
  }
`)

let drawInput: drawFunc = (c: canvas) => {
  let drawMarker = (c: canvas, pt: point, ~baseColor=ColorCode.black) => {
    let (x, y) = pt
    let f = (c: canvas, color: ColorCode.color, sz: int) => {
      c->fillColor(color)->drawRect((x-sz/2, y-sz/2), (sz, sz))
    }
    c
    ->f(baseColor, 30)
    ->f(ColorCode.white, 20)
    ->f(baseColor, 10)
  }
  let drawEdittingCross = (c: canvas) => {
    if state->isEditMode {
      let (w, h) = c->getSize
      let (x, y) = state.cursor.contents
      c
      ->strokeColor(ColorCode.black)
      ->drawLine((x, 0), (x, h))
      ->drawLine((0, y), (w, y))
      ->drawMarker((x, y), ~baseColor=ColorCode.red)
    } else {
      c
    }
  }
  let (pt1, pt2, pt3, pt4) = state.corners.contents

  c
  ->strokeWidth(10)
  ->strokeColor(ColorCode.red)
  ->drawLine(pt1, pt2)
  ->drawLine(pt2, pt3)
  ->drawLine(pt3, pt4)
  ->drawLine(pt4, pt1)
  ->drawMarker(pt1)
  ->drawMarker(pt2)
  ->drawMarker(pt3)
  ->drawMarker(pt4)
  ->drawEdittingCross
}

let drawOutput: drawFunc = (c: canvas) => {
  c
  ->transform(state.corners.contents)
}

let invokeDraw = (id: string, f: drawFunc) => {
  switch state.canvas.contents {
  | Some(c) =>
    c
    ->duplicateCanvas
    ->f
    ->setCanvas(id)
  | None => ()
  }
}

let invokeDrawInput = () => invokeDraw("#inputCanvas", drawInput)
let invokeDrawOutput = () => invokeDraw("#outputCanvas", drawOutput)

let loadImage = (files:array<fileType>) => {
  let file = files->Array.getUnsafe(0)
  initializeCanvas(file, (c: canvas) => {
    let (w, h) = c->getSize
    let (ux, uy) = (w / 10, h / 10)
    state.canvas := Some(c)
    state.corners := (
      (3*ux, uy),
      (7*ux, uy),
      (8*ux, 8*uy),
      (ux, 8*uy)
    )
    invokeDrawInput()
    invokeDrawOutput()
  })
}

let scalePoint = (pt: point): option<point> => {
  switch state.canvas.contents {
   | Some(c) =>
     let (x, y) = pt
     let (cw, ch) = c->getSize
     let (rw, rh) = getRectSize("#inputCanvas")
     Some((x * cw / rw, y * ch / rh))
   | None => None
  }
}

let invokeLoadImage = %raw(`function(e) { loadImage(e.target.files) }`)

let mousemove = (pt: point) => {
  if state->isEditMode {
    switch scalePoint(pt) {
    | Some(newPt) =>
      state.cursor := newPt
      invokeDrawInput()
    | None => ()
    }
  }
}

let invokeMousemove = %raw(`function (e) { mousemove([ e.offsetX, e.offsetY ]) }`)

let getNearestCornerPointIndex = (pt: point): int => {
  let (pt1, pt2, pt3, pt4) = state.corners.contents
  let arr: array<point> = [ pt1, pt2, pt3, pt4 ]
  let dists: array<int> = arr->Array.map((pti: point) => calcDist(pt, pti))
  let min: int = dists->Array.toSorted(Int.compare)->Array.getUnsafe(0)
  dists->Array.indexOf(min)
}

let click = (pt: point) => {
  switch scalePoint(pt) {
  | Some(newPt) =>
    if !(state->isEditMode) {
      state.editPointIndex := Some(getNearestCornerPointIndex(newPt))
    } else {
      switch state.editPointIndex.contents {
      | Some(i) =>
        let (pt1, pt2, pt3, pt4) = state.corners.contents
        state.corners := switch i {
        | 0 => (newPt, pt2, pt3, pt4)
        | 1 => (pt1, newPt, pt3, pt4)
        | 2 => (pt1, pt2, newPt, pt4)
        | _ => (pt1, pt2, pt3, newPt)
        }
        state.editPointIndex := None
        invokeDrawOutput()
      | None => ()
      }
    }
    invokeDrawInput()
  | None => ()
  }
}

let invokeClick = %raw(`function (e) { click([ e.offsetX, e.offsetY ]) }`)

Jq.domMake(Jq.document)->Jq.ready(() => {
  Jq.make("#load")->Jq.on("change", invokeLoadImage)->ignore
  Jq.make("#inputCanvas")->Jq.mousemove(invokeMousemove)->ignore
  Jq.make("#inputCanvas")->Jq.click(invokeClick)->ignore
})->ignore
