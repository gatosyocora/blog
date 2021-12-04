+++
title = "AnyStateを使用したAnimatorControllerの整理術"
date = "2021-12-05"
draft = true
tags = ["VRChat", "Unity", "Animator", "AnimatorController"]
+++

## はじめに

VRChat Advent Calender 2021の5日目の記事です。
https://adventar.org/calendars/6466

服などを切り替えるギミックを実装していると、魔法陣みたいなことになったことはありませんか。  
切り替えるものが増えていくと余計に管理が大変になります。

![](/images/posts/vrchat_advent_calender_2021/magic_states.png)

こんなときにはAnyStateが使えることが多いです。

![](/images/posts/vrchat_advent_calender_2021/any_state.png)

AnyStateを使うとこんな感じに整理できます。

![](/images/posts/vrchat_advent_calender_2021/magic_states_after.png)

整理することで
* 状態の変化がわかりやすくなる
* 新しい状態が追加されたときに引く矢印の数が少なくて済む

などのメリットがあります。

## AnyStateはどんな仕組み

変更前は1の状態はDefault, 2, 3, 4, 5に向けた矢印（赤色）とそれぞれから向けられた矢印(水色)があります。  
Default, 2, 3, 4, 5の状態も他の状態に向けた矢印と向けられた矢印があります。

![](/images/posts/vrchat_advent_calender_2021/magic_states_1_out.png)

![](/images/posts/vrchat_advent_calender_2021/magic_states_1_in.png)

それに対して、変更後は1の状態はAnyStateから向けられた矢印（水色）のみです。  
Default, 2, 3, 4, 5の状態もAnyStateから向けられた矢印のみです。

![](/images/posts/vrchat_advent_calender_2021/magic_states_after_1.png)

これはAnyStateが「どの状態ともみなせるもの」なのでこのような構成で表現できます。

AnyStateを1以外の状態とみなしたときに、これらの状態が1に向けた矢印を向けているようになります。  
つまり今回の例では、Default, 2, 3, 4, 5の状態が1に矢印を向けています。

![](/images/posts/vrchat_advent_calender_2021/any_state_other_than_1.png)

また、AnyStateを1の状態とみなしたときは、他の状態に矢印を向けているようになります。  
つまり今回の例では、1がDefault, 2, 3, 4, 5の状態に矢印を向けています。

![](/images/posts/vrchat_advent_calender_2021/any_state_1.png)

これで変更前のようにすべての状態に向けた矢印とそれらから向けられた矢印を表現できます。

## 注意点

AnyStateを使う時は**自分自身にも矢印が向いていること**に注意する必要があります。  
この状態だとAnyStateと1を常に切り替えるような挙動になり、他のユーザーに負荷をかけることがあります。

![](/images/posts/vrchat_advent_calender_2021/any_state_1_loop.png)

これを回避するためにはAnyStateから伸ばしたそれぞれの矢印の**Can Transition To Self**のチェックを外しておきます。  
これで自身の状態から同じ状態に切り替わることがなくなります。

![](/images/posts/vrchat_advent_calender_2021/can_transition_to_self.png)

## 矢印に設定する切り替える条件

服などの物を出し入れする場合は、矢印に設定する条件は基本的には「切り替えるパラメータがそれぞれ特定の数値と等しくなったとき」で良いです。

下の例の場合は、**Costume**が切り替えるパラメータでEquals(等しい)で0, 1, 2, ...と比較しています。  
これによってExpressionMenu[^1]でConstumeの値を1, 2, ...と切り替えたときに服などの表示するオブジェクトが切り替わるようにできます。

[^1]:VRChat内で使用できる円形のメニュー

![](/images/posts/vrchat_advent_calender_2021/arrows_setting.png)

服などの物を出し入れするギミックについては以下で解説しているので、こちらをご覧ください。  
[[VRChat] Avatars3.0で物を出し入れする (EmoteSwitchみたいなもの)](/posts/vrchat_avatars3_action_switch/)

## おわりに

今回はAnimatorControllerをAnyStateを使って整理する方法を紹介しました。  
AnimatorControllerでは他にも[SubStateMachine](https://docs.unity3d.com/ja/2019.4/Manual/NestedStateMachines.html)や[BlendTree](https://docs.unity3d.com/ja/2019.4/Manual/class-BlendTree.html)などの機能を使えばさらに整理することもできるので、こちらにも挑戦してみてください。

## 参考
- [Unityマニュアル アニメーションステート](https://docs.unity3d.com/ja/2019.4/Manual/class-State.html)
- [【Unity】AnimationControllerのAnyStateを使用してる際、現在のStateへ何度も移動しないようにする](https://tsubakit1.hateblo.jp/entry/2017/01/13/233000)
- [[VRChat] Avatars3.0で物を出し入れする (EmoteSwitchみたいなもの)](https://gatosyocora.hatenablog.com/entry/2020/08/08/164516)
