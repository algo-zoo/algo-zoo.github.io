+++
title = '最短経路探索'
draft = false
categories = ['visualizer']
tags = ['graph', 'shortest path']
[params]
    cdn = ['jquery', 'p5js']
    css = ['/css/nagitsuji.css']
    js = ['/js/nagitsuji.js']
+++

## 概要

* 椥辻駅・京都橘大学間の最短経路を[ダイクストラ法](../dijkstra)により求める例．
* 地図のグラフによるモデル化は，交差点等に頂点を設置することで徒歩の道を実現．また，辺の重みは「画面上のピクセル数」を設定することで地図上の実際の距離を近似している．

## ビジュアライザ

地図の画像は [OpenStreetMap](https://www.openstreetmap.org/copyright/ja) を使用．

<div id="canvas-hole"></div>
<div class="container">
  <div>
    <button class="alg-btn" id="image_load">画像ON/OFF</button>
    <button class="alg-btn" id="graph_draw">グラフON/OFF</button>
  </div>
  <div>
    <label>探索開始頂点</label><select id="start"></select>
    <button class="alg-btn" id="search">ワンステップ探索</button>
    <button class="alg-btn" id="goal">最終状態まで探索</button>
    <button class="alg-btn" id="reset">リセット</button>
  </div>
  <table border="1" id="tbl">
    <thead>
      <tr>
        <th>ノードi</th>
        <th>（暫定）最短経路の経路長さ d[i]</th>
        <th>（暫定）最短経路の頂点iの一つ前の頂点 prev[i]</th>
      </tr>
    </thead>
  </table>
</div>
