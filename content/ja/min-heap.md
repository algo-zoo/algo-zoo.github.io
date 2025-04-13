+++
title = 'Minヒープ'
draft = false
categories = ['visualizer']
tags = ['heap']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/heap.css']
    js = ['/js/MinHeap.js']
+++

## データ構造

* **概要:** 値を管理するための木構造で，データの挿入操作と最小値削除操作が共に高速に（＝ 木の高さを $h$ としたとき，$O(\log{h})$で）行えるデータ構造．
* **ヒープ条件:** Minヒープ $T$ は，以下の条件を満たす:
  * $T$ は **ほとんど完全な二分木(almost complete binary tree)** である．すなわち，$T$ の高さを $h$ としたとき，$T$の葉は左詰めで木を構築しており，$T$ の任意の葉は深さが $h$ か $h-1$ である．
  * $T$の任意の頂点 $u$ について，もしその子頂点 $v$ が存在するならば，$u$ の値はかならず $v$ の値以下である．

## アルゴリズム

### 挿入処理: `insert(v)`

* [Maxヒープ](/ja/max-heap)の場合とほぼ同様に定める．値の順序判定のみが異なる．

### 最小値削除処理: `delete()`

* [Maxヒープ](/ja/max-heap)の場合とほぼ同様に定める．値の順序判定のみが異なる．

## ビジュアライザ

<div class="container">
  <div>
    <label for="program">コマンド列</label><br>
    <textarea class="w-full" id="program"></textarea><br>
    <button class="alg-btn" id="run">実行</button>
  </div>
  <div>
    <label>Minヒープの処理（上部の配列は，二分ヒープの配列表現による配列）</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
