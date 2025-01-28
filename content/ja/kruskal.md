+++
title = 'クラスカル法'
draft = false
categories = ['visualizer']
tags = ['graph', 'minimum spanning tree']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/kruskal.js']
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

1. $\Vp, \Ep$の初期値はそれぞれ空集合とする．入力のグラフの辺集合 $E$ について，各辺を重みが小さい順にソートする．ソート結果の辺を順に $e_0, e_1, \ldots, e_{|E|-1}$とする．ただし，$|E|$は$E$の要素数を表す．
2. 各 $i = 0, 1, \ldots, (|E|-1)$に対して，以下を実行:
    * 辺 $e_i = (u_i, v_i)$ について，$\Ep$ に $e_i$ を追加することを考えたとき……
        * サイクルが形成されるならば，辺 $e_i$ を $\Ep$ に追加せず破棄;
        * サイクルが形成されないなら，$\Vp \gets \Vp \cup \lbrace u_i, v_i \rbrace$ と $\Ep \gets \Ep \cup \lbrace e_i \rbrace$により各集合を更新．
3. この時点で $\Vp = V$ であり，$(V, \Ep)$ が最小全域木となるので終了．

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
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
