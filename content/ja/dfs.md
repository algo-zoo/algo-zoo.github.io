+++
title = 'グラフに対する深さ優先探索(DFS)'
draft = false
categories = ['visualizer']
tags = ['graph']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/DFS.js']
+++

## 問題

* 入力: 有向グラフ $G = (V, E)$ と探索開始頂点 $s$
* 出力: $G$ を $s$ から深さ優先探索したときの訪問した頂点の列

## アルゴリズム

### 使用するデータ構造

$\gdef\svisited{\mathrm{visited}}$
$\gdef\visited#1{\svisited[{#1}]}$
$\gdef\null{\mathrm{null}}$

* $S$: 「探索予定の頂点を格納するためのスタック」
* $i$: 「現在の探索順番を記録するための数値変数」
* $\visited{u}$: 「頂点 $u$ が何番目に探索されたかを記録するための数値配列」

### 手続き
1. スタック $S$ に対し，探索開始頂点 $s$ を push する．また，$i \leftarrow 0$ とし，各頂点 $u \in V$ について $\visited{u} \leftarrow \null$ とする．
2. スタック $S$ が空になるまで，以下を繰り返し実行:
    - $S$ を pop して得られる要素を $u$ とする．以下を実行:
        - $\visited{u} = \null$ ならば，$\visited{u} \leftarrow i$ を実行して次に進む．
        - $\visited{u} \neq \null$ ならば，頂点 $u$ は探索済みだから，2.の処理を実行．
    - $u$ に隣接する各頂点 $v$ について$^{\dagger}$，以下を実行:
        - $\visited{v} = \null$ ならば，頂点 $v$ は未訪問であるから $v$ をスタックに push する．
        - $\visited{v} \neq \null$ ならば，訪問済み頂点であるから何もしない．
    - $i \leftarrow i + 1$ を実行．
3. この時点で深さ優先探索が終了し，$\visited{u}$に結果が格納されている．<br>（注: $\visited{v} = \null$ ならば開始頂点 $s$ から頂点 $v$ にはたどり着けない; $\visited{v} = j$ならば，頂点 $v$ は開始頂点から $j$ 番目に訪問される頂点）

#### 手続きの補足

- 上記の手続きは一例であり，他の実装方法もある．特に，今回の実装では pop 時点で $\svisited$ を更新しているが，push 時点で更新する方が一般的．なお，今回の実装ではスタックに同一要素が push される場合がある．
- 上記の $(\dagger)$ 部分の「$v$ に隣接する各頂点 $t$」について，どの隣接頂点を先に探索するかによって探索順に違いが現れる．そのため，何らかの規則によって探索順を規定することでアルゴリズムの出力を一意にできる．
    - 本ビジュアライザのサンプルでは，$(\dagger)$処理において，複数の頂点があり得る場合は，**辞書順で後に来る**ラベルの頂点から処理している．

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
  <label>探索開始頂点</label><select id="start"></select>
  <button class="alg-btn" id="search">ワンステップ探索</button>
  <button class="alg-btn" id="goal">最終状態まで探索</button>
  <button class="alg-btn" id="reset">リセット</button>
</div>


