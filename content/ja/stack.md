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

* **概要:** 後入れ先出し（LIFO: Last In First Out）、先入れ後出し（FILO: First In Last Out）の出し入れ順序でデータを格納する構造。
* **操作:**
  * `push(data)`: 要素 `data` をスタックに挿入する操作．
  * `pop()`: スタックから，スタック内にある要素の中で最後に挿入された要素を取り出す操作．

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
