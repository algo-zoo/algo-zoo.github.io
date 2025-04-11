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

* **概要:** 先入れ先出し（FIFO: First In First Out）、後入れ後出し（LILO: Last In Last Out）の出し入れ順序でデータを格納する構造。
* **操作:**
  * `enqueue(data)`: 要素 `data` をキューに挿入する操作．
  * `dequeue()`: キューから，キュー内にある要素の中で最初に挿入された要素を取り出す操作．

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
