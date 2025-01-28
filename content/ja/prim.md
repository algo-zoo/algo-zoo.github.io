+++
title = 'プリム法'
draft = false
categories = ['visualizer']
tags = ['graph', 'minimum spanning tree']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    globaljs = ['/js/concave-hull.js']
    js = ['/js/prim.js']
+++

## 問題

* 入力: 連結な重み付き無向グラフ $G = (V, E, w)$
* 出力: $G$ の最小全域木

## アルゴリズム

### 使用するデータ構造

$\gdef\Vp{V^\prime}$
$\gdef\Ep{E^\prime}$

* $\Vp$: 「（最小全域木を作る過程で）確定した頂点の集合」
* $\Ep$: 「（最小全域木を作る過程で）確定した辺の集合」

### 手続き

1. $\Ep$ の初期値は空集合とする．入力グラフの頂点集合 $V$ から，一つ要素を適当に決め $v_0$ とする．$\Vp \gets \lbrace v_0 \rbrace$で初期化．
2. $\Vp$ に含まれる頂点 $u$ と，$\Vp$ に含まれない頂点 $v$ を結ぶ辺 $(u, v)$ の中で，重みが最小な辺を選び，それを $(s, t)$ とする．次を順に実行:
    * $\Vp \gets \Vp \cup \lbrace s, t \rbrace$ とし，$\Ep \gets \Ep \cup \lbrace (s, t) \rbrace$ とする．
    * $\Vp = V$ ならば $(V, \Ep)$が最小全域木となるので終了．$\Vp \neq V$ならば 2. を繰り返し実行．

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
  <label>探索開始頂点</label><select id="start"></select>
  <button class="alg-btn" id="search">ワンステップ探索</button>
  <button class="alg-btn" id="goal">最終状態まで探索</button>
  <button class="alg-btn" id="reset">リセット</button>
  <table border="1" id="data_tbl">
    <thead>
      <tr>
        <th>辺</th>
        <th>重み</th>
        <th>（暫定）最小全域木の辺として採用</th>
      </tr>
    </thead>
  </table>
</div>
