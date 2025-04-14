const getRange = () => [ parseInt($('#begin').val())-1, parseInt($('#end').val()) ];

const getTarget = () => parseInt($('#target').val());

const setTarget = (v) => $('#target').val(v);

const setRandomTarget = function() {
  const [b, e] = getRange();
  setTarget(b + Math.floor(Math.random() * (e-b)) + 1);
}

const makeColorBar = function(x, y) {
  const [b, e] = getRange();
  const barB = 1.0 * (x-b) / (e-b) * 100;
  const barE = 1.0 * (y-b) / (e-b) * 100;
  const barWidth = barE - barB;
  const colorBar = (color, r) => $('<div>', {
    class: color,
    style: 'width: calc(' + r + '% - 1px)',
    html: '&nbsp;'
  });
  return $('<div>', {class: 'bar'}).append([
    colorBar('gray-bar', barB),
    colorBar('blue-bar', barWidth),
    colorBar('gray-bar', 100 - (barB + barWidth))
  ]);
}

const makeBar = function(text, x, y) {
  const textTag = $('<div>', {
    class: 'header-left',
    text: text
  });
  const rangeTag = $('<div>', {
    class: 'header-right',
    text: '【' + '探索範囲=' + (x+1) + '~' + y + ', 幅=' + (y-x) + '】'
  });
  return $('<div>').append([ textTag, rangeTag, makeColorBar(x, y) ]);
}

const makeRow = (a, b) => $('<tr>').append([
  $('<td>').css('width', '10%').append(a),
  $('<td>').css('width', '90%').append(b)
]);

const binarySearch = function() {
  const [b, e] = getRange();
  const target = getTarget();
  if (e < b) {
    alert('エラー: 始点は終点以下の値を指定してください');
  } else if (target < b || e < target) {
    alert('エラー: 答えの数値は探索範囲内を指定してください');
  } else {
    const tbody = $('#chat').empty().append($('<tbody>'));
    let text = '🤡（…… 答えの数は ' + target + ' だ！ ……）';
    let [cb, ce] = [b, e];
    makeRow('初期状態', makeBar(text, cb, ce)).appendTo(tbody);
    for (let cnt = 1; ce - cb >= 2; cnt++) {
      const mid = Math.floor((cb+ce)/2);
      text = '🤔「' + mid + '以下か？」 ⇒ ';
      if (target <= mid) {
        ce = mid;
        text += '🤡「Yes」';
      } else { // mid < target
        cb = mid;
        text += '🤡「No」';
      }
      makeRow(cnt + '回目', makeBar(text, cb, ce)).appendTo(tbody);
    }
    makeRow('答え', ce).appendTo(tbody);
  }
}

$(document).ready(function () {
  $('#random').on('click', setRandomTarget);
  $('#binary').on('click', binarySearch);
  setRandomTarget();
});

