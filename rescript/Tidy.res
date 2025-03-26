type fileType
type canvas
type image
type drawFunc = canvas => canvas
type cornerPoints = (int, int, int, int, int, int, int, int)

// ==== Canvas Utility ====
let drawPoint: (canvas, int, int) => canvas = %raw(`
  function (canvas, x, y) {
    const ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.arc(x, y, 5, 0, Math.PI * 2);
    ctx.fillStyle = "red";
    ctx.fill();
    return canvas;
  }
`)

let drawLine: (canvas, int, int, int, int) => canvas = %raw(`
  function (canvas, x1, y1, x2, y2) {
    const ctx = canvas.getContext("2d");
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
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

let strokeWidth: (canvas, int) => canvas = %raw(`
  function (canvas, width) {
    const ctx = canvas.getContext("2d");
    ctx.lineWidth = width;
    return canvas;
  }
`)

let getSize: canvas => (int, int) = %raw(`
  function (canvas) {
    return [canvas.width, canvas.height];
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

let corners: ref<cornerPoints> = ref((0, 0, 0, 0, 0, 0, 0, 0))

let setCorners = (pts: cornerPoints) => {
  corners := pts
}

let calcDist = (x1: int, y1: int, x2: int, y2: int): int => {
  let p1 = Math.pow(float_of_int(x2 - x1), ~exp=2.0)
  let p2 = Math.pow(float_of_int(y2 - y1), ~exp=2.0)
  int_of_float(Math.sqrt(p1 +. p2))
}

let transform: (canvas, cornerPoints) => canvas = %raw(`
  function (canvas, corners) {
    const ctx = canvas.getContext("2d");

    const [x1, y1, x2, y2, x3, y3, x4, y4] = corners;
    const widthTop = calcDist(x1, y1, x2, y2);
    const widthBottom = calcDist(x3, y3, x4, y4);
    const tarWidth = Math.max(widthTop, widthBottom);
  
    const heightLeft = calcDist(x1, y1, x4, y4);
    const heightRight = calcDist(x2, y2, x3, y3);
    const tarHeight = Math.max(heightLeft, heightRight);

    const fxCanvas = fx.canvas();
    const texture = fxCanvas.texture(canvas);
    fxCanvas.draw(texture)
      .perspective(
        [x1, y1, x2, y2, x3, y3, x4, y4],
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
  let (x1, y1, x2, y2, x3, y3, x4, y4) = corners.contents

  c
  ->strokeWidth(6)
  ->strokeColor(ColorCode.red)
  ->drawLine(x1, y1, x2, y2)
  ->drawLine(x2, y2, x3, y3)
  ->drawLine(x3, y3, x4, y4)
  ->drawLine(x4, y4, x1, y1)
}

let drawOutput: drawFunc = (c: canvas) => {
  c
  ->transform(corners.contents)
}

let invoke = (c: canvas, id:string, f: drawFunc) => {
  c
  ->duplicateCanvas
  ->f
  ->setCanvas(id)
}

let draw = (c: canvas) => {
  invoke(c, "#inputCanvas", drawInput)
  invoke(c, "#outputCanvas", drawOutput)
}

let loadImage = (files:array<fileType>) => {
  let file = files->Array.getUnsafe(0)
  initializeCanvas(file, (c: canvas) => {
    let (w, h) = c->getSize
    let (ux, uy) = (w / 10, h / 10)
    setCorners((3*ux, uy, 7*ux, uy, 8*ux, 8*uy, ux, 8*uy))
    draw(c)
  })
}

let invokeLoadImage = %raw(`function(e) { loadImage(e.target.files) }`)

Jq.domMake(Jq.document)->Jq.ready(() => {
  Jq.make("#load")->Jq.on("change", invokeLoadImage)->ignore
})->ignore
