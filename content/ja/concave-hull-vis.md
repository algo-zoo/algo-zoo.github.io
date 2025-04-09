+++
title = '凹包ビジュアライザ'
draft = false
categories = ['visualizer']
tags = ['concave hull']
[params]
    cdn = ['jquery', 'p5js']
    css = ['/css/graph.css']
    globaljs = ['/js/concave-hull.js']
    js = ['/js/DevConcaveHullVis.js']
+++

## ビジュアライザ

<div class="container">
  <div id="canvas-hole"></div>
  <div class="mt-2">
    <button class="alg-btn" id="random">ランダム生成</button>
    <button class="alg-btn" id="reset">リセット</button>
    <button class="alg-btn" id="prev">前へ</button>
    <button class="alg-btn" id="next">次へ</button>
  </div>
</div>
