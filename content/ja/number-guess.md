+++
title = '二分探索による数当て'
draft = false
categories = ['visualizer']
tags = ['binary search']
[params]
    cdn = ['jquery', 'katex']
    css = ['/css/number-guess.css']
    js = ['/js/NumberGuess.js']
+++

## 問題の状況設定

* あなたはピエロと数当てゲームをすることになった．
* ピエロは，ある整数$a, b$について$a$以上$b$以下の数値のうち，一つを選び，あなたには分からない形でその数値を記録する．
* あなたが，ピエロに対して何回か「YesかNoかで答えられる質問」をすることができたとする．
* このとき二分探索法に基づいた質問方法では何回の質問でその数値を与えることができるか？

## 二分探索法による質問方法

### 手続きのアイディア

* 候補となる探索範囲を毎回の質問で半分にする質問をする．例えば，探索する範囲のちょうど中間の整数 $m$ について「答えの数値は $m$ 以下ですか？」という質問をして範囲を半減させる．

### 手続きの一例

1. $b - a > 1$である間，すなわち，探索範囲の幅が1より大きい間は以下の処理を繰り返す:
  * $\displaystyle m \gets \left\lbrack \frac{a+b}{2} \right\rbrack$ とする（注: $\lbrack x \rbrack$は$x$の小数点以下を切り捨てて整数にする関数）
  * ピエロに対して「答えの数値は $m$ 以下ですか？」と質問し，回答に応じて場合分け:
    * Yesの場合: このとき $a$ 〜 $m$ に答えがあることが分かるから，$b \gets m$ で$b$を更新する．
    * Noの場合： このとき $(m+1)$ 〜 $b$ に答えがあることが分かるから，$a \gets m+1$ で$a$を更新する．
2. この時点で$a + 1 = b$となり探索幅が$1$となって答えが$b$に確定する．

## ビジュアライザ

<div class="container">
  <div class="mb-2">
    <label for="begin" class="block">始点</label>
    <input class="alg-input" type="number" id="begin" value="1">
  </div>
  <div class="mb-2">
    <label for="end" class="block">終点</label>
    <input class="alg-input" type="number" id="end" value="100">
  </div>
  <div class="mb-2">
    <label for="target" class="block">答えの数値</label>
    <input class="alg-input mb-1" type="number" id="target">
    <button class="alg-btn" type="button" id="random">自動生成</button>
  </div>
  <div>
    <label for="binary" class="block">探索</label>
    <button class="alg-btn" type="button" id="binary">実行</button>
  </div>
  <table id="chat">
  </table>
</div>


## 出典

* 『[アルゴリズム・クイックリファレンス 第2版](https://www.oreilly.co.jp/books/9784873117850/)』（George T. Heineman, Gary Pollice, Stanley Selkow 著; 黒川 利明, 黒川 洋 訳; オライリー・ジャパン 発行）の第1章「アルゴリズムで考える」の2.4.2節「対数的な振る舞い」に現れる問題例を改変．
