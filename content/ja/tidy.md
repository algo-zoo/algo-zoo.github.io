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

* 本アプリはアップロードされた画像を台形補正するツールです。
* 使用方法:
  1. アップロードボタンより、画像（JPG画像もしくはPNG画像）をアップロードする。
  2. アップロードされた画像と、台形補正用の４つのマーカーが表示されるので、４つのマーカーをマウスクリック・移動により適切な位置に移動させる。
  3. 適切な変換後の出力が得られたら、必要に応じてファイル名を変更し、保存ボタンを画像を保存する。

## 台形補正

### 元画像

<div class="container">
  <input class="alg-upload-input" aria-describedby="load_help" id="load" type="file" accept=".jpg, .jpeg, .png">
  <p class="alg-help-text" id="load_help">JPG画像またはPNG画像をアップロード</p>

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

