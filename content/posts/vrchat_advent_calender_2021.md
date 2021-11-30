+++
title = "見やすいAnimatorControllerを目指して"
date = "2021-12-05"
draft = true
tags = ["VRChat", "Unity", "Animator", "AnimatorController"]
+++

VRChat Advent Calender 2021の5日目の記事です。
https://adventar.org/calendars/6466

AnimatorControllerを整理するためのTipsをいくつか紹介します

## AnyStateを使用する

服を切り替えるギミックを実装していると、魔法陣みたいなことになったことはありませんか。  
服が増えていくと余計に管理が大変になりますね。

![](/images/posts/vrchat_advent_calender_2021/magic_states.png)

こういうときにはAnyStateが使えることが多いです。

![](/images/posts/vrchat_advent_calender_2021/any_state.png)

AnyStateを使うとこんな感じに整理できます。

![](/images/posts/vrchat_advent_calender_2021/magic_states_after.png)

整理することで
* 状態遷移がわかりやすくなる
* 新しい状態が追加されたときに引く矢印の数が少なくて済む

などのメリットがあります。

変更前は1の状態はDefault, 2, 3, 4, 5に向けた矢印（赤色）とそれぞれから向けられた矢印(水色)があります。他の状態も同じです。

![](/images/posts/vrchat_advent_calender_2021/magic_states_1_out.png)

![](/images/posts/vrchat_advent_calender_2021/magic_states_1_in.png)

それに対して、変更後は1の状態はAnyStateから向けられた矢印（水色）のみです。他の状態も同じです。

![](/images/posts/vrchat_advent_calender_2021/magic_states_after_1.png)

これはAnyStateが「どの状態ともみなせる状態」なのでこのような構成で表現できます。

AnyStateを1以外の状態とみなしたときに、これらの状態が1に向けた矢印を向けているようになります。

![](/images/posts/vrchat_advent_calender_2021/any_state_other_than_1.png)

また、AnyStateを1の状態とみなしたときは、他の状態に矢印を向けているようになります。

![](/images/posts/vrchat_advent_calender_2021/any_state_1.png)

これで変更前のようにすべての状態に向けた矢印とそれらから向けられた矢印を表現できます。

ただし、AnyStateを使う時の注意点は自分自身にも矢印が向いていることです。  
この状態だとAnyStateと1を常に行き来するような挙動になり、他人に負荷をかけることがあります。

![](/images/posts/vrchat_advent_calender_2021/any_state_1_loop.png)

これを回避するためにはAnyStateから伸ばしたそれぞれの矢印の**Can Transition To Self**のチェックを外しておきます。  
これで自分自身から遷移することがなくなります。

![](/images/posts/vrchat_advent_calender_2021/can_transition_to_self.png)

矢印に設定する条件は基本的には切り替えるパラメータがそれぞれ0, 1, 2, ...と等しくなったときで良いです。

![](/images/posts/vrchat_advent_calender_2021/arrows_setting.png)

# 参考
- [Unityマニュアル アニメーションステート](https://docs.unity3d.com/ja/2019.4/Manual/class-State.html)
- [【Unity】AnimationControllerのAnyStateを使用してる際、現在のStateへ何度も移動しないようにする](https://tsubakit1.hateblo.jp/entry/2017/01/13/233000)
- [[VRChat] Avatars3.0で物を出し入れする (EmoteSwitchみたいなもの)](https://gatosyocora.hatenablog.com/entry/2020/08/08/164516)
