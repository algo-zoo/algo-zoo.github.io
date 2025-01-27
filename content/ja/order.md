+++
title = 'オーダー評価'
draft = false
categories = ['visualizer']
tags = ['limit']
[params]
    cdn = ['jquery', 'p5js', 'katex', 'fplot']
    css = ['/css/order.css']
    js = ['/js/order.js']
+++

## 概要

### オーダー記法の定義

* 時間計算量を表す関数 $T(x)$ のオーダーが関数 $f(x)$ を用いて $T(x) = O(f(x))$ で表せるとは，ある自然数 $N_0$ と正の実数 $c$ があって，$N_0$ 以上の任意の自然数 $N$ について，次が成り立つとき言う: $\displaystyle |T(N)| \leq c \cdot |f(N)|$

## ビジュアライザ

<div class="container">
  <label>各種定義</label>
  <div class="alg-box light-red">
    <label for="function">時間計算量関数: $T(x)$</label>
    <input class="alg-input" id="function" type="text" value="3*x + 123" onchange="reload();">
    <input type="radio" name="function_viz" value="1" checked>グラフ表示</input>
    <input type="radio" name="function_viz" value="0">グラフ非表示</input>
  </div>

  <div class="alg-box light-gray">
    <label for="order">オーダー表現用の関数: $f(x)$</label>
    <input class="alg-input" id="order" type="text" value="x" onchange="reload();">
    <input type="radio" name="order_viz" value="1">グラフ表示</input>
    <input type="radio" name="order_viz" value="0" checked>グラフ非表示</input>
  </div>

  <div class="alg-box light-blue">
    <label for="const_c">関数 $c \cdot f(x)$ の定数: $c$</label>
    <input class="alg-input" id="const_c" type="text" value="2" onchange="reload();">
    <input type="radio" name="c_viz" value="1">グラフ表示</input>
    <input type="radio" name="c_viz" value="0" checked>グラフ非表示</input>
  </div>

  <div class="alg-box zebra">
    <label for="const_n">定数: $N_0$</label>
    <input class="alg-input" id="const_n" type="text" value="0" onchange="reload();">
    <input type="radio" name="n_viz" value="1">グラフ表示</input>
    <input type="radio" name="n_viz" value="0" checked>グラフ非表示</input>
  </div>

  <label>関数$f(x)$による関数$T(x)$のオーダー評価の成否の簡易チェック</label>
  <div class="alg-box">
    <ul>
      <li>
        定数$\,c\,$の値を <span class="blue-text bold" id="c_view"">????</span> とし，
        定数$\,N_0\,$の値を <span class="blue-text bold" id="n0_view">????</span> とする．
      </li>
      <li>
        このとき，$N_0\,$以上の任意の$\,N\,$について$\,|T(N)| \leq c \cdot |f(N)|\,$が……
        「<span class="bold" id="result1">????</span>」
        <ul>
          <li>（☝  本当はここの不等式が成り立つかをちゃんと証明しないとダメ）</li>
        </ul>
      </li>
      <li>
        よって，$T(N) = O(f(N))$が……
        「<span class="bold" id="result2">????</span>」
      </li>
    </ul>
  </div>

  <div id="plot">
    <label for="graph">グラフ</label>
    <div id="graph"></div>
  </div>
</div>
