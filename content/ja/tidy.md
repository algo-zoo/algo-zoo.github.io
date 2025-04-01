+++
title = '画像の台形補正ツール'
draft = false
categories = ['tool']
tags = ['tool']
[params]
    cdn = ['jquery', 'glfx']
    css = ['/css/tidy.css']
    js = ['/js/Tidy.js']
+++

## 概要

* **TODO**

## 台形補正

### 元画像

<div class="container">
  <input class="alg-upload-input" aria-describedby="load_help" id="load" type="file" accept=".jpg, .jpeg, .png">
  <p class="alg-help-text" id="load_help">JPG画像またはPNG画像をアップロードt</p>

  <canvas id="inputCanvas"></canvas>
  <div id="rotate-button-container">
    <button class="alg-btn" id="ccw">↶ 左回転</button>
    <button class="alg-btn" id="cw">右回転 ↷</button>
  </div>
</div>

### 変換後の画像

<div class="container">
  <canvas id="outputCanvas"></canvas>
  <label for="file_name">保存時のファイル名</label>
  <div class="display: flex">
    <input class="alg-input" id="file_name" type="text" placeholder="保存時のファイル名"></input>
    <label class="ml-2 mt-1">.jpg</label>
  </div>
  <button class="alg-btn mt-2" id="save">保存</button>

</div>

