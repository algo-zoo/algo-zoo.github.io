+++
title = 'グラフに対する幅優先探索(BFS)'
draft = false
categories = ['visualizer']
tags = ['graph']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/BFS.js']
+++

## 問題

* 入力: 有向グラフ $G = (V, E)$ と探索開始頂点 $s$
* 出力: **TODO**

## アルゴリズム

### 使用するデータ構造

* **TODO**

### 手続き

* **TODO**

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
  <label>探索開始頂点</label><select id="start"></select>
  <button class="alg-btn" id="search">ワンステップ探索</button>
  <button class="alg-btn" id="goal">最終状態まで探索</button>
  <button class="alg-btn" id="reset">リセット</button>
</div>


