+++
title = '迷路の最短経路探索'
draft = false
categories = ['visualizer']
tags = ['graph', 'shortest path']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/maze.css']
    js = ['/js/Maze.js']
+++

## 問題

$\gdef\map{\mathrm{map}}$
$\gdef\sdist{\mathrm{dist}}$
$\gdef\dist#1#2{\sdist[#1][#2]}$
$\gdef\xp{x^\prime}$
$\gdef\yp{y^\prime}$

* 入力: 障害物のマスを記録した二次元配列 $\map$，スタート座標 $(sx, sy)$，ゴール座標 $(gx, gy)$．
    * 備考: スタートからゴールまでの経路が一つは存在することを仮定する．
* 出力: スタート座標からゴール座標まで，四方向移動で移動したときの最短経路長．

## アルゴリズム

### 使用するデータ構造

* $\sdist$:「各マスの（暫定）最短経路長を記録するための二次元配列」
* $d$:「（暫定）最短経路長を記録するための変数」

### 手続き

1. $d \gets 0$とする．スタート座標 $(sx, sy)$ についてのみ $\dist{sy}{sx} \gets 0$とし，それ以外の各座標 $(x, y)$ について $\dist{y}{x} \gets \infty$とする．
2. $\dist{y}{x} = d$ となるような各 $(x, y)$ を探索対象として，以下を実行:
  * $(x, y) = (gx, gy)$ならば，最短経路長として $d$ を返して終了;
  * $(x, y) \neq (gx, gy)$ならば，$(x, y)$から（$\map$の障害物情報を考慮しつつ）一回の移動（注: 移動可能マスは上下左右で障害物が無いマス）で辿り着ける座標 $(\xp, \yp)$ について，$\dist{\yp}{\xp} \gets \mathrm{min}\lbrace \dist{\yp}{\xp}, (d+1) \rbrace$ とする．
3. 距離が $d$ の場合の更新処理を全て終えた後，$d \gets (d+1)$として 2. を繰り返す．

## ビジュアライザ

<div class="container">
  <div>
    <label for="setting">迷路の設定</label>
    <select class="alg-select mb-1" name="setting" id="maze-select">
      <option value="0">カスタム</option>
      <option value="1">サンプル1</option>
      <option value="2">サンプル2</option>
    </select>
    <label>入力</label>
    <textarea class="w-full" rows="12" id="maze-input"></textarea>
    <button class="alg-btn" id="maze-load">設定</button>
  </div>
  <div>
    <label>迷路の最短経路探索</label>
    <div class="mb-1" id="canvas-hole"></div>
    <div class="text-center">
      <button class="alg-btn" id="prev">前へ</button>
      <button class="alg-btn" id="next">次へ</button>
    </div>
  </div>
</div>
