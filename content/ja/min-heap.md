+++
title = 'Minヒープ'
draft = false
categories = ['visualizer']
tags = ['heap']
[params]
    cdn = ['jquery', 'p5js']
    css = ['/css/heap.css']
    js = ['/js/min-heap.js']
+++

## 問題

* **TODO: write. dual to Max heap**

## アルゴリズム

* **TODO: write. dual to max heap**

## ビジュアライザ

<div class="container">
  <div>
    <label for="program">コマンド列</label><br>
    <textarea class="w-full" id="program"></textarea><br>
    <button class="alg-btn" id="run">実行</button>
  </div>
  <div>
    <label>Minヒープの処理</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
