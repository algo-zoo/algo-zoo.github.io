+++
title = 'キュー'
draft = false
categories = ['visualizer']
tags = ['queue']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    js = ['/js/QueueVis.js']
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
    <label>キューの処理</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
