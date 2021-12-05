+++
title = "Editor拡張的にみたUnity2019でできるようになること"
date = "2021-07-24T00:00:00+09:00"
tags = ["Unity", "Editor拡張", "Unity2019"]
categories = ["Unity"]
author = "gatosyocora"
description = "UnityEditor関連で2019バージョンから使えるようになった機能やAPI、変更点などをまとめています"
meta_image = "images/og/unity2019_editor_extension.png"
+++

VRChatで使用しているUnityEditorのバージョンが2018.4.20f1から2019.4.28f1になります。  
Unity2019になったときにUnityEditor拡張的にはどのようなことができるようになるかを調べてまとめてました。  
他にも見つかれば追記していきます。

# 新機能

## UIElements

Editor拡張のGUI部分をXAML的な記法で作ることができるようになりました。  
従来の作り方でも作ることができますが、GUI作成を支援する機能も備わっているので移行するのはありだと思います。  
ちなみにもっと後のUnityのバージョンではこの名称は`UI Toolkit`に変わっているようです。

https://docs.unity3d.com/ja/2019.4/Manual/UIElements.html

## Unity Package Manager (UPM)

プロジェクト内のUnityPackageを管理できる機能です。  
この機能を使用してインポートしたUnityPackageが管理されます。  
管理されているUnityPackageは新しいバージョンがあるとこの機能の画面から最新バージョンをインストールできます。
https://docs.unity3d.com/ja/2019.4/Manual/Packages.html

## Addressable Asset System

リソースを読み込むための新しい方法が増えました。  
従来の`Resources.Load`に変わる方法として提案されています。  
この機能を使用するにはPackageManagerでこの機能を追加するためのUnityPackageをインポートする必要があるようです。

https://docs.unity3d.com/ja/2019.4/Manual/com.unity.addressables.html

## EditorTools

SceneView上でGameObjectやComponentを操作しやすくする機能を実装するためのAPIが増えました。

https://learning.unity3d.jp/5002/

https://blog.yucchiy.com/2020/09/editor-tools/

# 変更点

## AssetDatabase V2 (Experimental)

V2ということで内部的に大幅変更されてそうです。  
しかし、V1と同じAPIを使用できるので、この変更で関連するスクリプトを変更する必要はないようです。  
GUIDの持ち方は変わるみたいなのでGUIDのファイルを直接参照するようなものは変更する必要があるかもしれないですね。  
また、キャッシュサーバーを使ってインポートやプラットフォーム切り替えを高速化するようですが、そのために`Unity Accelerator`を使用するようです。

https://learning.unity3d.jp/4584/

## EditorStyles

新しく使えるようになったスタイルがあったり、全体的に見た目が変わっていたりします。  

### 新しく使えるようになったもの
* EditorStyles.linkLabel
* EditorStyles.foldoutHeader
* EditorStyles.foldoutHeaderIcon
* EditorStyles.toolbarSearchField

https://hacchi-man.hatenablog.com/entry/2020/04/05/220000

# 廃止(Obsolete)
* SceneView#onSceneGUIDelegate
  * https://github.com/Unity-Technologies/UnityCsReference/blob/86305f755ec65987bd8de18f3e38bc608adc0ba3/Editor/Mono/SceneView/SceneView.cs#L368


  * 代わりに SceneView#duringSceneGuiか SceneView#beforeSceneGuiを使う
