+++
title = '二分探索'
draft = false
categories = ['visualizer']
tags = ['binary search']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/binary-search.css']
    js = ['/js/BinarySearch.js']
+++

## 問題

* 入力: 長さ $N$ の昇順ソート済みの配列 $a$ と探索したい値 $v$
* 出力: $a[i] = v$ となる $v$ が存在するならば $i$ を，存在しないならばその旨を返す．

## アルゴリズム

### 使用するデータ構造

$\gdef\vleft{\mathrm{left}}$
$\gdef\vright{\mathrm{right}}$
$\gdef\vmid{\mathrm{mid}}$

* $\vleft$:「探索範囲の左端の添字を格納するための変数」
* $\vright$:「探索範囲の右端の添字を格納するための変数」
* $\vmid$:「探索範囲の中間点の添字を格納するための変数」

### 手続き

1. $\vleft \gets 0$ と $\vright \gets (N-1)$ で各変数を初期化．
2. $\vleft \leq \vright$が成立する間，以下を繰り返す:
    * $\displaystyle\vmid \gets \left\lbrack \frac{\vleft + \vright}{2} \right\rbrack$ とする（注: $\lbrack x \rbrack$は$x$の小数点以下を切り捨てて整数にする関数）
    * $a[\vmid]$ の値に応じて以下の通り場合分け:
        * $a[\vmid] = v$ ならば，値が存在したことになるので添字 $\vmid$ を返して終了;
        * $a[\vmid] < v$ ならば，$\vleft \gets (\vmid + 1)$ として 2. を繰り返す;
        * $a[\vmid] > v$ ならば，$\vright \gets (\vmid - 1)$ として 2. を繰り返す．
3. この部分に達した場合，配列 $a$ 中に $v$ が存在しないので，その旨を返して終了．

## ビジュアライザ

<div class="container">
  <div class="mb-2">
    <label for="size">配列要素数</label>
    <input class="alg-input mb-1" type="number" id="size" value="16"></input>
    <button class="alg-btn" id="generate">入力の生成</button>
  </div>
  <div class="mb-2">
    <label for="array">入力: 数値配列</label>
    <input class="alg-input mb-1" type="text" id="array"></input>
    <button class="alg-btn" id="set">設定</button>
  </div>
  <div class="mb-2">
    <label>配列状態・探索状況</label>
    <div id="canvas-hole"></div>
  </div>
  <div class="mb-2">
    <label for="begin">探索する値（＝配列に存在するか判定する値）</label><br>
    <input class="alg-input" type="number" id="target" value="0"></input>
  </div>
  <div class="mb-2">
    <button class="alg-btn" id="run">ワンステップ実行</button>
    <button class="alg-btn" id="reset">リセット</button>
  </div>
  <div>
    <label>実行記録</label><br>
    <textarea class="w-full" rows="12" id="textbox" disabled></textarea>
  </div>
</div>

