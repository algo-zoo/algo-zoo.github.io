+++
title = 'グラフに対する幅優先探索(BFS)'
draft = false
categories = ['visualizer']
tags = ['graph']
[params]
    cdn = ['jquery', 'p5js', 'katex']
    css = ['/css/graph.css']
    js = ['/js/BFS.js']
+++

## 問題

* 入力: 有向グラフ $G = (V, E)$ と探索開始頂点 $s$
* 出力: $G$ を $s$ から幅優先探索したときの訪問した頂点の列

## アルゴリズム

<!--
### 使用するデータ構造

$\gdef\sdist{\mathrm{dist}}$
$\gdef\dist#1{\sdist[{#1}]}$

* $Q$: 「探索予定の頂点を格納するためのキュー」
* $\dist{u}$: 「頂点 $u$ が何番目に探索されたかを記録するための数値配列」

### 手続き

1. キュー $Q$ に対し，探索開始頂点 $s$ を enqueue する．また，$\dist{s} \leftarrow 0$ とし，開始頂点 $s$ 以外の各頂点 $v$ について $\dist{v} \leftarrow \infty$ とする．
2. キュー $Q$ が空になるまで，以下を繰り返し実行:
    - $Q$ を dequeue して得られる要素を $v$ とする．
    - $v$ に隣接する各頂点 $t$ について$^{\dagger}$，以下を実行:
        - $\dist{t} = \infty$ ならば，未訪問頂点なので，$t$ をキューに enqueue し，$\dist{t} \leftarrow \dist{v} + 1$ とする．
        - $\dist{t} \neq \infty$ ならば，訪問済みもしくは訪問予定の頂点であるから，何もしない．
3. この時点で幅優先探索が終了し，$\sdist$ に結果が格納されている．<br>（注: $\dist{v} = \infty$ ならば開始頂点 $s$ から頂点 $v$ にはたどり着けない; $\dist{v} = j$ならば，頂点 $v$ は開始頂点から $j$ 番目に訪問される頂点）
-->

### 使用するデータ構造

$\gdef\seen#1{\mathrm{seen}[{#1}]}$
$\gdef\null{\mathrm{null}}$

* $Q$: 「探索予定の頂点を格納するためのキュー」
* $i$: 「現在の探索順番を記録するための数値変数」
* $\seen{u}$: 「頂点 $u$ が何番目に探索されたかを記録するための数値配列」

### 手続き
1. キュー $Q$ に対し，探索開始頂点 $s$ を enqueue する．また，$i \leftarrow 0$ とし，各頂点 $u \in V$ について $\seen{u} \leftarrow \null$ とする．
2. キュー $Q$ が空になるまで，以下を繰り返し実行:
    - $Q$ を dequeue して得られる要素を $u$ とする．$\seen{u} \leftarrow i$ を実行．
    - $u$ に隣接する各頂点 $v$ について$^{\dagger}$，以下を実行:
        - $\seen{v} = \null$ かつ $ \not\in Q$ ならば，未訪問頂点であり訪問予定でもないので $v$ をキューに enqueue する．
        - そうでないなら（つまり，$\seen{v} \neq \null$ または $v \in Q$ ならば），訪問済みもしくは訪問予定の頂点であるから，何もしない．
    - $i \leftarrow i + 1$ を実行．
3. この時点で幅優先探索が終了し，$\seen{u}$に結果が格納されている．<br>（注: $\seen{v} = \null$ ならば開始頂点 $s$ から頂点 $v$ にはたどり着けない; $\seen{v} = j$ならば，頂点 $v$ は開始頂点から $j$ 番目に訪問される頂点）

#### 手続きの補足

- 上記の $(\dagger)$ 部分の「$v$ に隣接する各頂点 $t$」について，どの隣接頂点を先に探索するかによって探索順に違いが現れる．そのため，何らかの規則によって探索順を規定することでアルゴリズムの出力を一意にできる．
- 本ビジュアライザのサンプルでは，$(\dagger)$処理において，複数の頂点があり得る場合の探索順は，**辞書順で先に来る**ラベルの頂点から探索している．

## ビジュアライザ

{{< adjacent-matrix-graph >}}

<div class="container">
  <label>探索開始頂点</label><select id="start"></select>
  <button class="alg-btn" id="search">ワンステップ探索</button>
  <button class="alg-btn" id="goal">最終状態まで探索</button>
  <button class="alg-btn" id="reset">リセット</button>
</div>


