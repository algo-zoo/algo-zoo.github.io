+++
title = 'ダイクストラ法'
draft = false
categories = ['visualizer']
tags = ['graph', 'shortest path']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/dijkstra.css']
    js = ['/js/Dijkstra.js']
+++

## 問題

* 入力: 辺の重みが非負である重み付きグラフ $G = (V, E, w)$ と探索開始頂点 $s$
* 出力: 開始頂点 $s$ から辿れる各頂点 $v$ について，経路長が最短の $s$-$v$ ウォーク

## アルゴリズム

### 使用するデータ構造

$\gdef\dist#1{\mathrm{dist}[{#1}]}$
$\gdef\prev#1{\mathrm{prev}[{#1}]}$
$\gdef\null{\mathrm{null}}$
$\gdef\weight#1#2{w(#1, #2)}$

* $S$:「すでに最短経路が確定している頂点の集合」
* $\dist{v}$:「開始頂点 $s$ から頂点 $v$ までの（暫定）最短経路の長さ」
* $\prev{v}$:「開始頂点 $s$ から頂点 $v$ の（暫定）最短経路で，$v$ の前に位置する頂点」

### 手続き

1. $S$ の初期値は空集合とする．開始頂点 $s$ について $\dist{s} \gets 0$ で初期化し，$s$ 以外の各頂点 $v$ は $\dist{v} \gets \infty$ で初期化．また，（$s$ も含めた）各頂点 $v$ について $\prev{v} \gets \null$ とする．
2. $v \not\in S$ である頂点の中で $\dist{v}$ の値が最小の頂点を求め，それを $u$ とする．
    * $u$ に隣接する各頂点 $t$ について，次を実行: $\dist{t} > \dist{u} + \weight{u}{t}$ ならば，
$\dist{t} \gets \dist{u} + \weight{u}{t}$ と $\prev{t} \gets u$ の更新．なお，ここで $\weight{u}{t}$ は辺 $(u, t)$ に定義された重みの値とする．
    * $S \gets S \cup \lbrace u \rbrace$とする．$S = V$ ならば終了で，そうでないなら 2. の処理を繰り返す．

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
  <div class="mt-2">
    <label>探索開始頂点</label><select id="start"></select>
    <button class="alg-btn" id="search">ワンステップ探索</button>
    <button class="alg-btn" id="goal">最終状態まで探索</button>
    <button class="alg-btn" id="reset">リセット</button>
  </div>
  <table class="border" id="data_tbl">
    <thead>
      <tr>
        <th>ノードi</th>
        <th>最短経路が確定</th>
        <th>（暫定）最短経路の経路長 dist[i]</th>
        <th>（暫定）最短経路における頂点iの一つ前の頂点 prev[i]</th>
      </tr>
    </thead>
  </table>
  <div>注意: グラフ上の，経路が確定した頂点にマウスをかざすと具体的な最短経路を表示可能</div>
</div>
