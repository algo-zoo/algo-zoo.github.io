+++
title = 'Maxヒープ'
draft = false
categories = ['visualizer']
tags = ['heap']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/heap.css']
    js = ['/js/MaxHeap.js']
+++

## 問題

* **TODO: write**

## Maxヒープの配列表現

* **TODO: write**

## アルゴリズム

### 挿入処理: insert

* 値 $x$ の挿入は以下の通り実行:
    1. ヒープの最後尾に $x$ を値として持つ頂点を追加
    2. 追加した頂点と，その親の頂点との間でヒープ条件が満たされない場合……
        * 追加した頂点と，その親頂点とを交換
        * ヒープ条件が満たされるまで同様の処理を根の方に向かって行う

### 最大値削除処理: delete

* 最大値を持つ頂点（＝根の頂点）の削除は以下の通り実行:
    1. 根の頂点を削除し，最後尾の頂点を根に一時的に移す
    2. 移された頂点と，その子の頂点との間でヒープ条件が満たされない場合……
        * 移された頂点と子の頂点を交換する（注: このとき，子頂点が２つあるならば値が大きい方と交換する）
        * ヒープ条件が満たされるまで同様の処理を葉の方に向かって行う

## ビジュアライザ

<div class="container">
  <div>
    <label for="program">コマンド列</label><br>
    <textarea class="w-full" id="program"></textarea><br>
    <button class="alg-btn" id="run">実行</button>
  </div>
  <div>
    <label>Maxヒープの処理</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
