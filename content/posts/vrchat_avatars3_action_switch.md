+++
title = "[VRChat] Avatars3.0で物を出し入れする (EmoteSwitchみたいなもの)"
date = "2020-08-08T00:00:00+09:00"
tags = [ "Unity", "VRChat", "Avatars3.0" ]
categories = ["VRChat"]
author = "gatosyocora"
meta_image = "images/og/vrchat_avatars3_action_switch.png"
+++

# はじめに
これまでのアバター(Avatars2.0)では  
Emote(エモート)機能でオブジェクトを出したり、消したりするギミック（通称：[EmoteSwitch](https://keiki002.com/vr/vrc-emoteswitch/)）がありました。

Avatars 3.0ではアクションメニューを拡張してボタンを追加することで、  
そのボタンの操作によってオブジェクトを出したり、消したりできるようになりました。  

これはEmoteSwitch(エモートスイッチ)に比べて、  

* <b>単純な設計で実装できる</b>
* <b>後からインスタンスに来た人にもオブジェクトの状態が同期する</b>
* <b>多くのオブジェクトの出し入れを管理できる</b>
* <b>ワールドを移動してもオブジェクトの状態が維持されるようにできる</b>

などメリットがいくつもあります。 

この記事ではAvatars3.0のアクションメニューのToggleボタン操作によって、  
後から来た人にも同期するようにオブジェクトを出し入れするギミック(以下、ActionSwitch)を実装する方法を解説します。 

[2020/8/31]  
2つ以上の物を入れ替えるときに一瞬同時に出てしまう問題を解消する方法を<a href="#20200831">追記</a>しました。

[2021/1/10]  
WriteDefaultsの注意について<a href="#20210110">追記</a>しました。

[2021/3/26]  
ギミックに使用するParameterの種類を<b>Int</b>から<b>Bool</b>に変更しました。  
WriteDefaultsがオフを想定した内容に変更しました。

<b>動作確認環境</b>

* Unity 2018.4.20f1
* VRCSDK3-AVATAR-2021.03.22.18.27_Public.unitypackage

# 実装する手順

この記事では実装手順の紹介なのでCubeを使ってオブジェクトの出し入れを紹介します。  
他のもの（服や武器など）の出し入れの場合は本記事のCubeの部分を置き換えて実装してみてください。

<p id="20210110"></p>
【注意】（2021/1/10, 3/26追記）  
以下は各StateのWriteDefaultsがオフ(チェックが入っていない)を想定しています。  
オンとオフが混在している場合、ギミックがうまく動作しないことがあるので注意してください。

![](/images/posts/vrchat_avatars3_action_switch/write_defaults_on.png)

## 大まかな手順
1. <b>FXに設定されたAnimatorControllerに新しいLayerを追加する</b>  
（これに対してStateを追加したりしていく）
    * weightが1になっているか確認
2. <b>初めから存在するEntry, AnyState, Endに加えて、新しく以下のStateを追加する</b>
    * CubeOFF : Cubeが出ていない状態（デフォルト状態）
    * CubeON : Cubeが出ている状態（アクティブ状態）
3. 各StateのWriteDefaultsをオフ（チェックが入っていない状態）にする
4. <b>Entry->CubeOFF->CubeON->Endとなるように遷移の矢印を追加する</b>
5. <b>AnimationParameterにBool型の「ActiveCube」というパラメータを追加する（初期値false）</b>
6. <b>遷移の矢印に以下の設定をする</b>
    * CubeOFF -> CubeON
        * Conditions : ActiveCube true
        * Has Exit Time : false
        * Transition Duration(s) : 0 [2020/8/31追記]
    * CubeON -> End
        * Conditions : ActiveCube false
        * Has Exit Time : false
        * Transition Duration(s) : 0 [2020/8/31追記]
7. <b>CubeONに以下のようなAnimationClipを設定する</b>
    * CubeのActiveをtrue (表示) にする
    * 0フレーム目にのみキーを持つ
8. <b>CubeOFFに以下のようなAnimationClipを設定する</b>
    * CubeのActiveをfalse (表示) にする
    * 0フレーム目にのみキーを持つ
8. <b>CubeのデフォルトのActiveはfalse (非表示) にしておく</b>
10. <b>Expression ParametersにBool型の「ActiveCube」というパラメータを追加する</b>
11. <b>Expressions Menuに以下のようなControlを追加する</b>
    * Type : Toggle
    * Parameter : ActiveCube

## 1. ActionSwitchの実装の準備

VRCAvatarDescriptorのPlayable Layersの<b>FX</b>に設定されたAnimatorControllerをダブルクリックして選択します。  
（まだ設定されていない場合、<b>Assets/VRCSDK/Examples3/Animation/Controllers</b>にある<b>vrc_AvatarV3HandsLayer</b>を複製してここに設定してください。）

次に、選択された状態でAnimatorウィンドウを開きます。  
（Unity上部の<b>Window>Animation>Animator</b>で開けます。）
![](/images/posts/vrchat_avatars3_action_switch/open_animator_tab.png)

左上にある<b>「+」</b>を押して新しいLayerを作成します。  
Layerには分かりやすい名前をつけてください。  
今回はCubeを出すのでCubeという名前をつけました。  
Debugメニューで文字化けしてしまうため、日本語ではなく英語の名前にしたほうがよいです。

![](/images/posts/vrchat_avatars3_action_switch/create_new_layer.png)

次に右のほうにある歯車のマークをクリックして、  
以下の画像のようなLayerの設定画面を開きます。  

![](/images/posts/vrchat_avatars3_action_switch/layer_setting.png)

<b>Weightの項目を0から1に変更してください。</b>  
このようにLayerのWeightを1にしないと、  
そのLayerでの変更はアバターに反映されないので注意が必要です。（よく忘れがち）

![](/images/posts/vrchat_avatars3_action_switch/layer_weight.png)

これで新しいギミックを作成する準備は完了です。  
この流れは今回紹介するActionSwitchだけでなく、  
多くのギミックを新しく実装する手順に含まれる操作です。  

## 2. ActionSwitchの実装

今回はActionSwitchを使って、  
Cubeを出したり、消したりしていきます。  
以下の画像が完成したときのStateとParameterです。  
これを目指して作っていきます。  
![](/images/posts/vrchat_avatars3_action_switch/result.png)

### 2.1 Stateの作成と設定

このギミックはCubeが出ている状態と出ていない状態の2つの状態でできています。  
先ほどの画像では  

* <b>橙色</b>のStateが<b>Cubeが出ていない状態(デフォルト状態)</b>  
* <b>灰色</b>のStateが<b>Cubeが出ている状態(アクティブ状態)</b>  

のようになっています。  

まず、まだCubeを出していないデフォルト状態を作成します。  
何もない場所で右クリックして、  
<b>Create State>Empty</b>で新しいStateを作成します。

![](/images/posts/vrchat_avatars3_action_switch/create_new_state.png)

![](/images/posts/vrchat_avatars3_action_switch/default_steate_only.png)

同じ手順でCubeが出ているアクティブ状態のStateも作成します。

![](/images/posts/vrchat_avatars3_action_switch/new_state.png)

それぞれのStateをクリックするとInspectorに詳細が表示されます。  

![](/images/posts/vrchat_avatars3_action_switch/state_inspector.png)

ここの名前部分を選択して、それぞれのStateを分かりやすい名前にしておきましょう。  
Debugメニューで文字化けしてしまうため、日本語ではなく英語の名前にしたほうがよいです。

<b>CubeOFF</b> : Cubeが出ていない状態（デフォルト状態）橙色  
<b>CubeON</b>：Cubeが出ている状態（アクティブ状態）灰色

![](/images/posts/vrchat_avatars3_action_switch/cube_on_off_states.png)

また、[VRChat公式](https://docs.vrchat.com/docs/avatars-30#write-defaults-on-states)ではWriteDefaultsはオフを推奨しているのでこちらも<b>チェックを外しておきましょう</b>

![](/images/posts/vrchat_avatars3_action_switch/write_default_off.png)

次にState同士を矢印でつないでいきます。  
CubeOFFのStateを右クリックして、<b>Make Transition</b>を選択します。

![](/images/posts/vrchat_avatars3_action_switch/make_transition.png)

すると矢印がついた白線がマウスに追従するのでその状態でCubeONのStateをクリックします。  
これでCubeOFFからCubeONへの矢印（遷移, Transition）が追加されました。  

![](/images/posts/vrchat_avatars3_action_switch/cube_off_to_on_transition.png)

同じように今度はCubeONからExit（赤色のState）に向けて矢印を追加します。  

![](/images/posts/vrchat_avatars3_action_switch/select_transition_of_on_to_exit.png)

###  2.2 Parameterの作成と設定

次にStateから別のStateへの移動の条件を設定するためにParameterを設定します。  

Layersの横にある<b>Parameters</b>をクリックして、  
そのAnimatorControllerに設定されたAnimationParameterの一覧を表示します。

![](/images/posts/vrchat_avatars3_action_switch/controller_parameters.png)

左上にある<b>「+」</b>をクリックして新しいParameterを追加します。  
今回はオブジェクトを出し入れするのでBoolを選択します。  

![](/images/posts/vrchat_avatars3_action_switch/add_controller_parameter_bool.png)

名前はActiveCubeにしました。  
特にこれでないといけないわけではないですが、  
以降でActiveCubeを選択・設定するときに同じ名称になるようにしてください。  
また、日本語ではなく英語の名前にしたほうがよいです。

![](/images/posts/vrchat_avatars3_action_switch/add_active_cube_parameter_in_controller.png)

次にLayersを押してLayer一覧に戻り、記事序盤で作成した<b>「Cube」レイヤー</b>を選択します。   

![](/images/posts/vrchat_avatars3_action_switch/select_layers_tab.png)

![](/images/posts/vrchat_avatars3_action_switch/select_cube_layer.png)

CubeOFFとCubeONの間にある矢印をクリックします。  
するとInspectorに矢印の詳細が表示されます。  

![](/images/posts/vrchat_avatars3_action_switch/select_transition_of_off_to_on.png)

![](/images/posts/vrchat_avatars3_action_switch/cube_off_to_on_setting.png)

Conditionsの<b>「+」</b>をクリックして新しい項目を追加します。  
![](/images/posts/vrchat_avatars3_action_switch/default_conditions.png)

左から順に<b>ActiveCube, true</b>に変更します。  
これでCubeOFFにいるときにActiveCubeというParameterがtrue(チェックが入った状態)になったらCubeONに移動します。  

![](/images/posts/vrchat_avatars3_action_switch/select_active_cube_in_conditions.png)

さらに<b>Has Exit Timeのチェックを外します。</b>  

![](/images/posts/vrchat_avatars3_action_switch/has_exit_time_off.png)

<p id="20200831"></p>
[2020/8/31追記]<br>
また、Settingsにある<b>Transition Duration (s) を0にします。</b><br>
これはStateの遷移にかける時間で、0より大きい場合、State間の状態が補完されながら遷移されます。

![](/images/posts/vrchat_avatars3_action_switch/transition_duration_0.png)

これでCubeが出ていないデフォルト状態からCubeが出ているアクティブ状態にするギミック部分はできました。  

次にCubeが出ているアクティブ状態からCubeが出ていないデフォルト状態に戻す部分を作っていきます。  

CubeONのStateとExitのStateの間にある矢印を選択します。  
![](/images/posts/vrchat_avatars3_action_switch/select_transition_of_on_to_exit.png)

先ほどと同じような手順でConditionsとTransition Duration, Has Exit Timeを以下のように設定します。


<b>Has Exit Time : チェックを外す</b>  
<b>Transition Duration (s) : 0</b>  
<b>Conditions : ActiveCube false</b>  

![](/images/posts/vrchat_avatars3_action_switch/cube_on_to_exit_setting.png)

###  2.3 Animationの作成と設定

アバターにCubeを追加します  
(説明用にCubeを追加しているので、  
このCubeが今回出し入れしたいものだと考えてもらって大丈夫です)

<b>Cubeの代わりにするオブジェクトにAnimatorがついている場合には削除してください。</b>

![](/images/posts/vrchat_avatars3_action_switch/hierarchy.png)
![](/images/posts/vrchat_avatars3_action_switch/ukon_with_cube.png)

#### 2.3.1 表示状態にするAnimation(CubeOn)の作成

まず、Projectウィンドウで右クリックをして、  
<b>Create>AnimationでAnimationClip</b>を作成します。  
Cubeを出すアニメーションなのでCubeOnという名前にしました。

![](/images/posts/vrchat_avatars3_action_switch/create_animation_file.png)
![](/images/posts/vrchat_avatars3_action_switch/create_cube_on_animation_file.png)

次に先ほど触っていたAnimatorControllerに戻って、
CubeONのStateを選択します。  
![](/images/posts/vrchat_avatars3_action_switch/select_cube_on_state.png)

CubeONのmotionに先ほど作成したCubeOnというAnimationClipを設定します。  

![](/images/posts/vrchat_avatars3_action_switch/cube_on_state_inspactor.png)

Animationの設定のために一時的に  
アバターのルートにあるAnimatorの<b>Controller</b>に  
FXに設定されているAnimatorControllerを設定します。

![](/images/posts/vrchat_avatars3_action_switch/set_controller_to_animator.png)

VRCAvatarDescriptorが設定されたオブジェクトを選択している状態で  
Animationウィンドウを開きます。  

![](/images/posts/vrchat_avatars3_action_switch/select_vrc_avatar_descriptor_object.png)

AnimationウィンドウはUnity上部の<b>Window>Animation>Animation</b>で開けます。  

![](/images/posts/vrchat_avatars3_action_switch/open_animation_tab.png)

左側にあるPreviewの下をクリックすると、  
先ほどAnimatorに設定したAnimatorControllerが持つAnimationClipの一覧が表示されます。  
先ほど設定したCubeOnを選択してください。

![](/images/posts/vrchat_avatars3_action_switch/select_cube_on_animation.png)

Previewの横の録画ボタンをクリックすると、録画モードが開始されます。  

![](/images/posts/vrchat_avatars3_action_switch/start_recoding.png)

この状態で出現させたいオブジェクト（本記事ではCube）を選択します。  

![](/images/posts/vrchat_avatars3_action_switch/select_cube_object.png)

<p id="onanimation"></p>
そしてInspectorの左上にあるチェックマークを<b>入っている状態</b>にします。  
最初から入っている場合はチェックボックスを一度押して再度押して入っている状態にしてください。  
下の画像のようになれば大丈夫です。  

![](/images/posts/vrchat_avatars3_action_switch/active_cube_object.png)

すると先ほどのAnimationウィンドウにCubeのIs Activeを操作するキーが0:00のところに追加されました。
これがチェックマークが入っている状態になっていることを確認してください。  

![](/images/posts/vrchat_avatars3_action_switch/add_cube_activate_key_in_recoding.png)

これで録画は完了なので、Previewボタンを一度押して<b>録画モードを停止してください。</b>  

![](/images/posts/vrchat_avatars3_action_switch/add_cube_activate_key.png)

これでAnimationの準備は完了なので、AnimatorからAnimatorControllerを外しておきましょう。  
Controllerの右の方にある二重丸を選択して一番上にあるNoneを選択すると外すことができます。  

![](/images/posts/vrchat_avatars3_action_switch/unselect_controller_in_animator.png)
![](/images/posts/vrchat_avatars3_action_switch/select_none_in_animator.png)

<p id="defaultstate"></p>
Cubeは最初は消えている状態にするのでチェックを外して消しておきましょう。  

![](/images/posts/vrchat_avatars3_action_switch/inactive_cube_object.png)

#### 2.3.2 非表示状態にするAnimation(CubeOff)の作成

次にCubeを初期状態の非表示状態にするAnimationを作成します。  
先ほど作成したCubeOn.animを選択した状態でCtrl+Dを押すと複製されます。

![](/images/posts/vrchat_avatars3_action_switch/duplicate_animation_file.png)

複製されたCubeOn 1を右クリックして<b>Rename</b>で<b>CubeOff</b>という名前に変更します。

![](/images/posts/vrchat_avatars3_action_switch/rename_animation_file.png)

Animatorウィンドウを開いて、CubeOFFステートのMotionに複製したCubeOffを設定します。

![](/images/posts/vrchat_avatars3_action_switch/set_cube_off_animation_file.png)

CubeOff.animを選択した状態でAnimationウィンドウを開くとその内容が見れます。  

![](/images/posts/vrchat_avatars3_action_switch/open_cube_off_animation.png)

<p id="offanimation"></p>
<b>Cube : Game Object.Is Active    1</b>のようになっているので、1のところをクリックし、<b>0</b>に変更します。  
これでCubeを非表示状態にするAnimationファイルになりました。

![](/images/posts/vrchat_avatars3_action_switch/cube_off_animation_value_1.png)
![](/images/posts/vrchat_avatars3_action_switch/cube_off_animation_value_0.png)

これでギミック部分は完成しました。

###  2.4 ExMenuの設定

最後にメニュー操作でオブジェクトを出し入れできるようにします。

VRCAvatarDescriptorのExpressionsの<b>Parameters</b>に設定しているExpressionParametersをダブルクリックして選択します。  

![](/images/posts/vrchat_avatars3_action_switch/select_expression_parameters.png)

設定されていない場合は<b>Create>VRChat>Avatars>Expression Parameters</b>で新しく作成して設定してください。

![](/images/posts/vrchat_avatars3_action_switch/create_expression_parameter.png)

左上の<b>Add</b>を押すと新しい項目が増えるのでNameに<b>ActiveCube</b>と入力してTypeは<b>Bool</b>を選択してください。  
ここの名称はAnimatorControllerのParametersで新しく設定した名称と同じにしてください。  
（大文字小文字も同じになるように）

DefaultはCubeが最初出ていない状態なので<b>チェックがない状態</b>にします。  
Savedは別のワールドやVRChatの再起動でもCubeが出ている状態を維持するために<b>チェックがある状態</b>にします。（ここはお好みでどちらでも良いです）

![](/images/posts/vrchat_avatars3_action_switch/set_active_cube_parameter_in_expression_parameters.png)
![](/images/posts/vrchat_avatars3_action_switch/add_active_cube_parameter_in_controller.png)

次にVRCAvatarDescriptorのExpressionsの<b>Menu</b>に設定しているExpressionsMenuをダブルクリックして選択します。  

![](/images/posts/vrchat_avatars3_action_switch/select_expression_menu.png)

設定されていない場合は<b>Create>VRChat>Avatars>Expressions Menu</b>で新しく作成して設定してください。

![](/images/posts/vrchat_avatars3_action_switch/create_expression_menu.png)

<b>Add Control</b>を押して新しい項目を増やします。  
既に項目が8個ある場合は追加できないので、  
ExpressionMenuを新しくしてSubMenuとして追加することを検討してください。

![](/images/posts/vrchat_avatars3_action_switch/add_control_in_expression_menu.png)

NameとIconは分かりやすいように設定してください。  
Typeは<b>Toggle</b>, Parameterは<b>ActiveCube, Bool</b>に設定してください。  

![](/images/posts/vrchat_avatars3_action_switch/set_detail_in_expression_menu.png)

これですべての設定が完了です。  
VRChatにアップロードしてCubeを出してみましょう。  

![](/images/posts/vrchat_avatars3_action_switch/preview.gif)

# 3. 注意点（おさらい）
* 新しく作成したLayerはweightが0になっているので1にする
* オブジェクトの出し入れのギミックはFX Layerに設定したAnimatorControllerに追加する
* Expression ParametersとAnimatorControllerのParameterの名称は完全に同じにする
* AnimatorControllerにあるStateのWriteDefaultsはオフ（チェックが入っていない状態）にする

# 4.応用編
## デフォルトで表示されているものを消す
本記事で紹介したものは「消えているものを表示する」でしたが、  
その逆も紹介した方法の応用で実現できます。  
おおまかな設定手順は同じで以下のものを変更します。

* 出し入れするオブジェクトの左上のチェックを入れて表示されている状態にしておく(<a href="#defaultstate">工程</a>)
* 設定するAnimationClipでIs Activeにチェックをはずす(<a href="#onanimation">工程</a>)
* 1を0に変更ではなく、0になっているので1に変更する(<a href="#offanimation">工程</a>)

初期状態と変更後にどういう状態にするかを変えただけです。  
これで「表示されているものを消す」というギミックになります。

# さいごに
今回紹介した方法は個人的に最小構成でActionSwitchを実装する方法だと思います。  
Expression Parametersの節約や初期状態でオブジェクトが出ているようにする方法など、応用する方法がいろいろあります。  

また、これだけ長い手順なので毎回設定するのは大変です。  
同じようなことを実現する方法としてこのようなツールも出ているので使ってみてもいいかもしれないです。  
いろんな方が作っておられるので用途と自分にあったツールを選ぶのが良いと思います。

[Radial Inventory System V3](https://booth.pm/ja/items/2278448)  

[VRC-Inventory](https://github.com/Merlin-san/VRC-Inventory)
