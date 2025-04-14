window.reload = function() {
  plot();
  order();
}

function orderCheck() {
  const func_t = $("#function").val();
  const func_f = $('#order').val();
  const c = parseInt($('#const_c').val());
  const n0 = parseInt($('#const_n').val());

  // いくつかのデータで不等号の成否を簡易チェック
  var data = [ n0 ];
  const addData = function(v) {
    if (n0 < v)
      data.push(v);
  }
  for (let i = 1; i <= 100; i++) {
    addData(n0 + i);
    addData(n0 / 10 * i);
  }
  const max_x = 1000000;
  for (let x = 0; x < max_x; x += max_x / 100) {
    addData(x);
  }

  for (const x of data) {
    const tv = Math.abs(functionPlot.$eval.builtIn({fn: func_t}, 'fn', {x: x}));
    const fv = Math.abs(functionPlot.$eval.builtIn({fn: func_f}, 'fn', {x: x}));
    if (!(tv <= c * fv))
      return false;
  }
  return true;
}

function order() {
  const c = $('#const_c').val();
  $('#c_view').html(c);
  const n0 = $('#const_n').val();
  $('#n0_view').html(n0);

  const ret = orderCheck();
  $('#result1').html(ret ? '成立 ⭕' : '不成立 ❌');
  $('#result2').html(ret ? '証明完了 ⭕' : '証明失敗 ❌');
}

function plot(first = false) {
  $('#graph').html('');

  const [xmin, xmax] = [-500, 500];
  const [ymin, ymax] = [-500, 500];
  const width = $('#plot').width();
  const parameters = {
    target: '#graph',
    width: width,
    height: width,
    data: [],
    grid: true,
    yAxis: { domain: [xmin, xmax] },
    xAxis: { domain: [ymin, ymax] },
    tip: {
      xLine: true,
      yLine: true
    },
  };

  const selectCheck = (name) => parseInt($('input[name=' + name + ']:checked').val());

  if (selectCheck('function_viz')) {
    const func_t = $("#function").val();
    parameters.data.push({
      fn: func_t,
      graphType: 'polyline',
      color: 'RGB(255, 75, 0)',
      attr: { 'stroke-width': 2 }
    });
  }

  if (selectCheck('order_viz')) {
    const func_f = $('#order').val();
    parameters.data.push({
      fn: func_f,
      graphType: 'polyline',
      color: 'black',
      attr: { 'stroke-width': 2 }
    });
  }

  if (selectCheck('c_viz')) {
    const func_cf = $('#const_c').val() + '*(' + $('#order').val() + ')';
    parameters.data.push({
      fn: func_cf,
      graphType: 'polyline',
      color: 'RGB(0, 90, 250)',
      attr: { 'stroke-width': 2 }
    });
  }

  if (selectCheck('n_viz')) {
    const n0 = $('#const_n').val();
    parameters.data.push({
      fn: 'x - ' + n0,
      fnType: 'implicit',
      color: 'black',
      attr: { 'stroke-width': 4, 'stroke-dasharray': '0.1,0.5' }
    });
  }

  functionPlot(parameters);
}

$(document).ready(function() {
  $('input[type="radio"]').change(reload);
  $(window).resize(reload);
  reload();
});

