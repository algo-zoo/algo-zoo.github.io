+++
title = 'スタック'
draft = false
categories = ['visualizer']
tags = ['stack']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/StackVis.js']
+++

## データ構造

* **TODO**

## ビジュアライザ

<div class="container">
  <div>
    <label for="program">コマンド列</label><br>
    <textarea class="w-full" id="program"></textarea><br>
    <button class="alg-btn" id="run">実行</button>
  </div>
  <div>
    <label>スタックの処理</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
