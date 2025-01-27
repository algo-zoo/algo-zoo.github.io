+++
title = 'マージソート'
draft = false
categories = ['visualizer']
tags = ['sort']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/merge-sort.js']
+++

## 概要

* マージソートは整列アルゴリズムの一種で，以下の特徴を持つ:
    * 配列を半分に分割し，左右それぞれを再帰的にソートして，その両者の結果を併合することを繰り返すことで配列を整列させる．分割統治法に基づくアルゴリズムの一例．
    * 配列の長さを $N$ としたとき，平均計算量も最悪計算量も $O(N \log{N})$ となることが知られている．

## アルゴリズム

長さが $N$ の配列 $a$ を昇順にソートするには，以下の `MergeSort` 関数を `MergeSort(a, 0, N)` で呼び出すことで実現される．

### 用語の定義

$\gdef\arr{\mathrm{arr}}$

- 自然数 $a, b$ について，集合 $\lbrace x \mid a \leq x < b \rbrace$ を $[a, b)$ で表す．いわゆる，左閉右開であるような半開区間．
- 配列 $\arr$ と自然数 $a, b$ について，その部分配列 $\arr\[a\], \arr\[a+1\], \arr\[a+2\], \ldots, \arr[b-1]$ を $\arr\[a, b)$ という記法で表す（ 注: $\arr[b]$は含まない ）．

### 擬似コード

```
// 配列 a の 区間 [left, right) 部分，すなわち a[left, right) をソートする関数
MergeSort(a, left, right) {
  if 区間 [left, right) のサイズが1 {
    return;
  } else {
    mid = (left + right) / 2;   // 区間の中間値を算出（注: 小数点以下がある場合は切り捨てて自然数にする）
    MergeSort(a, left, mid);    // 左区間 a[left, mid) を再帰的にソート
    MergeSort(a, mid, right);   // 右区間 a[mid, right) を再帰的にソート
    Merge(a, left, mid, right); // ２つのソート済み配列をマージ
  }
}

// ソート済みな a[left, mid) と a[mid, right) をマージすることでソート済みの a[left, right) を作る関数
Merge(a, left, mid, right) {
  buf = 空配列; // データ退避用に空配列 buf を用意
  左区間 a[left, mid) と右区間 a[mid, right) の両方が空になるまで次の①, ②を繰り返し {
    ① 場合分けにより以下の３つのうちの当てはまる１つを実行:
      ①-(a) 左区間も右区間も要素が空でないとき: 「左区間の最小値」と「右区間の最小値」を比較し，小さい方を該当区間から抜き出して変数 v に格納;
      ①-(b) 左区間の要素が空のとき: 「右区間の最小値」を当該区間から抜き出して変数 v に格納;
      ①-(c) 右区間の要素が空のとき: 「左区間の最小値」を当該区間から抜き出して変数 v に格納;
    ②  配列 buf に変数 v の値を追加;
  }
  buf の中身を a[left, right) にコピーする;
}
```

## ビジュアライザ

<div class="container">
  <div class="mb-2">
    <label for="size">配列要素数</label>
    <input class="alg-input mb-1" type="number" id="size" value="8"></input>
    <button class="alg-btn" id="generate">入力の生成</button>
  </div>
  <div class="mb-2">
    <label for="array">入力: 数値配列</label>
    <input class="alg-input mb-1" type="text" id="array"></input>
    <button class="alg-btn" id="set">実行</button>
  </div>
  <div>
    <label>マージソートの処理</label>
    <div id="canvas-hole"></div>
  </div>
</div>
