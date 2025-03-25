type fileType
type canvas
type image
type context

type cornerPoints = (int, int, int, int, int, int, int, int)
let corners: ref<cornerPoints> = ref((0, 0, 0, 0, 0, 0, 0, 0))

let setCorners = (pts: cornerPoints) => {
  corners := pts
}

let cropCanvas = %raw(`
  function (canvas, w, h) {
    const cropped = document.createElement("canvas");
    cropped.width = w;
    cropped.height = h;
    const ctx = cropped.getContext("2d");
    ctx.drawImage(canvas, 0, 0, w, h, 0, 0, w, h);
    return cropped;
  }
`)

let drawPoint: (context, int, int) => unit = %raw(`
  function (ctx, x, y) {
    ctx.beginPath();
    ctx.arc(x, y, 5, 0, Math.PI * 2);
    ctx.fillStyle = "red";
    ctx.fill();
  }
`)

let drawLine: (context, int, int, int, int) => unit = %raw(`
  function (ctx, x1, y1, x2, y2) {
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    ctx.stroke();
  }
`)

let getColorCode: ColorCode.color => string = %raw(`
  function (color) {
    return "rgb(" + color[0] + "," + color[1] + "," + color[2] + ")";
  }
`)

let strokeColor: (context, ColorCode.color) => unit = %raw(`
  function (ctx, color) {
    ctx.strokeStyle = getColorCode(color);
  }
`)

let strokeWidth: (context, int) => unit = %raw(`
  function (ctx, width) {
    ctx.lineWidth = width;
  }
`)

type drawFunc = context => unit

let getSize: image => (int, int) = %raw(`
  function (img) {
    return [img.width, img.height];
  }
`)

let drawImage: (context, image) => unit = %raw(`
  function (ctx, img) {
    ctx.drawImage(img, 0, 0);
  }
`)

let reader: (string, fileType, drawFunc) => unit = %raw(`
  function (id, file, draw) {
    const canvas = $(id)[0];
    const ctx = canvas.getContext("2d");
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = function() {
      const data = reader.result;
      const img = new Image();
      img.src = data;
      img.onload = function () {
        canvas.width = img.width;
        canvas.height = img.height;
        const ux = img.width / 10
        const uy = img.height / 10
        setCorners([ 3*ux, uy, 7*ux, uy, 8*ux, 8*uy, ux, 8*uy ])
        drawImage(ctx, img);
        draw(ctx);
      }
    }
  }
`)

let calcDist = (x1: int, y1: int, x2: int, y2: int): int => {
  let p1 = Math.pow(float_of_int(x2 - x1), ~exp=2.0)
  let p2 = Math.pow(float_of_int(y2 - y1), ~exp=2.0)
  int_of_float(Math.sqrt(p1 +. p2))
}

let transform: (context, cornerPoints) => unit = %raw(`
  function (ctx, corners) {
    const [x1, y1, x2, y2, x3, y3, x4, y4] = corners;
    const widthTop = calcDist(x1, y1, x2, y2);
    const widthBottom = calcDist(x3, y3, x4, y4);
    const tarWidth = Math.max(widthTop, widthBottom);
  
    const heightLeft = calcDist(x1, y1, x4, y4);
    const heightRight = calcDist(x2, y2, x3, y3);
    const tarHeight = Math.max(heightLeft, heightRight);
  
    const canvas = ctx.canvas;

    const fxCanvas = fx.canvas();
    const texture = fxCanvas.texture(canvas);
    fxCanvas.draw(texture)
      .perspective(
        [x1, y1, x2, y2, x3, y3, x4, y4],
        [0, 0, tarWidth, 0, tarWidth, tarHeight, 0, tarHeight]
      )
      .update();

    const cropped = cropCanvas(fxCanvas, tarWidth, tarHeight);
    const ctx2 = cropped.getContext("2d");
    canvas.width = cropped.width;
    canvas.height = cropped.height;
    ctx.drawImage(cropped, 0, 0);
  }
`)

let drawInput: drawFunc = (ctx: context) => {
  let (x1, y1, x2, y2, x3, y3, x4, y4) = corners.contents
  ctx->strokeWidth(6)
  ctx->strokeColor(ColorCode.red)
  ctx->drawLine(x1, y1, x2, y2)
  ctx->drawLine(x2, y2, x3, y3)
  ctx->drawLine(x3, y3, x4, y4)
  ctx->drawLine(x4, y4, x1, y1)
}

let drawOutput: drawFunc = (ctx: context) => {
  ctx->transform(corners.contents)
}

let draw = (file:fileType) => {
  reader("#inputCanvas", file, drawInput)
  reader("#outputCanvas", file, drawOutput)
}

let loadImage = (files:array<fileType>) => {
  let file = files->Array.getUnsafe(0)
  draw(file)
}

let invokeLoadImage = %raw(`function(e) { loadImage(e.target.files) }`)

Jq.domMake(Jq.document)->Jq.ready(() => {
  Jq.make("#load")->Jq.on("change", invokeLoadImage)->ignore
})->ignore
