# Notes On Programming in TeX

## 1  Introduction

This document is intended to provide a direct start with TeX programming (not necessarily TeX typesetting). The addressed audience consists of people interested in package or library writing.
At the time of this writing, this document is far from complete. Nevertheless, it might be a good starting point for interested readers. Consult the literature given below for more details.

```admonish
この文書は、TeXプログラミング（必ずしもTeX組版ではない）を直接始めるためのものである。この文書を書いている時点では、この文書はまだ完全ではありません。とはいえ、興味のある読者にとっては良い出発点になるかもしれない。詳細は後述の文献を参照されたい。
```

## 2  Programming in TeX

### 2.1 Variables in Registers

TeX provides several different variables and associated registers which can be manipulated freely.

```admonish
TeXには、自由に操作できるいくつかの変数と関連レジスタが用意されている。
```

`\count<num>`

There are 256 Integer registers which provide 32 Bit Integer arithmetics. THe registers can be used for example with `\count=42` or `\count7=\macro` where `\macro` expands to a number. The value of a register can be typeset using `the<register>`.

```admonish
32ビット整数演算を行う256個の整数レジスタがある。これらのレジスタは例えば `count=42` や `count7=macro` で使用することができる。レジスタの値は `the<register>` を使ってタイプセットすることができる。
```

The precise rules can be found in[2], but it should be kept in mind that care needs to be taken here. More than once, my code failed to produce the expected result because TeX kept exxpanding macros and the registers got unexpected results. Here is the correct method.

```admonish
正確な規則は[2]にあるが、ここでは注意が必要であることを覚えておく必要がある。TeXがマクロを拡張し続け、レジスタが予期せぬ結果を得たため、私のコードが期待した結果を出せなかったことが一度や二度ではない。以下が正しい方法である。
```

```text
1. The value is now `42'.
2. The following code will absorb the `3' of '3.':
. The value is now `12343'.
4. Use nrelax after an assignment to end scanning:
5. The value is now `1234'.
```

```latex
1. \count0=42 % a white space after the number aborts the reading process. It is discarded.
The value is now `\the\count0'.
2. The following code will absorb the `3' of '3.':
\def\macro{1234}
\count0=\macro % a white space after a macro will be absorbed by TeX, so this is wrong.
3. The value is now `\the\count0'.
4. Use \textbackslash relax after an assignment to end scanning:
\count0=\macro\relax
5. The value is now `\the\count0'.
```

The command `\relax` tells TeX to "relax": it stops scanning for tokens, but `\relax` doesn't expand to anything.

```admonish
relax`コマンドはTeXに "relax "を指示する：トークンのスキャンを止めるが、 `relax` は何も展開しない。
```

`\dimen<num>`

There are also 255 registers for fixed point numbers which are used pretty much in the same way as the `\count` registers -- but `\dimen` register assignments require a unit like 'cm' or 'pt'.
String access with `\the` works in exactly the same way as for `\count` registers.

```admonish
しかし、`dimen` レジスタの割り当てには 'cm' や 'pt' のような単位が必要である。 `the` による文字列アクセスは `count` レジスタと全く同じように動作する。
```

`\toks<number>`

There are also 255 token registers which can be thought of as special string variables. Of course, every macro assignment `\def\macro{<content>}` is also some kind of string variable, but token registers are special: their content won't be expanded when used with `\the\toks<number>`. This can be used for fien gained expansion control, see Section 2.3 below.

```admonish
また、255個のトークンレジスタがあり、これは特別な文字列変数と考えることができる。もちろん、マクロの代入`defdefmacro{<content>}`もある種の文字列変数であるが、トークン レジスタは特別で、`thetettoks<number>`と一緒に使っても内容が展開されない。これは、以下のセクション2.3を参照してください。
```

```text
The value is now abcDEF
```

```latex
\toks0={abc}%
\toks1={DEF}%
The value is now \the\toks0 \the\toks1.
```

Note the white space after `\the\toks0`: its purpose is to stop number parsing when TeX scans for 0. The white space is discarded.
Token registers can also contain the special token `#` which would typically have a special meaning inside of macros:

```admonish
thethetoks0`の後の空白に注意: この空白は、TeXが0をスキャンしたときに数値の解析を停止するため のものである。 トークンレジスタは、通常マクロの中で特別な意味を持つ特別なトークン `#` を含むこともできる：
```

```latex
\toks0={#1}%
\message{Meaning is \the\toks0}%
```

This outputs "Meaning is ##1" in your log file.
Token registers are mainly useful when it comes to fine grained expansion control and are discussed in more depth in Section 2.3.

```admonish
これは、ログファイルに "Meaning is ##1 "と出力される。 トークン・レジスタは、主に細かな拡張制御を行う場合に有用であり、セクション2.3で詳しく説明する。
```

### 2.1.1 Allocating Registers

There is a very limited number of registers. Consequently, one has to think carefully how to allocate them. Typical use-cases for registers are temporary variables (like some intermediate result) and long-living resources which are to be accumulated while the document or some part of its is to be generated.

- `\newdimen(\macroname)`
- `\newcount(\macroname)`
- `\newtoks(\macroname)`

## 2.3  Expansion Control

Expansion is what TeX does all the time. Thus, expansion control is a key concept for understanding how to program in TeX.

```admonish
拡張はTeXが常に行っていることです。したがって、展開制御はTeXのプログラミング方法を理解するための重要な概念である。
```

The first thing to know is: TeX deals the input as long, long sequence of "tokens". A token is the smallest unit which is understood by TeX. Each character becomes a token the first time it is seen by TeX. Every macro becomes a (single!) token the first time it is een by TeX.

```admonish
まず知っておくべきことはTeXは入力を長い長い「トークン」の列として扱う。トークンとは、TeXが理解できる最小単位である。各文字はTeXが最初に見たときにトークンになります。すべてのマクロは、TeXが初めて見たときに（単一の！）トークンになります。
```

The second thing to know is what characters are *before* TeX has seen them. Although this sknowledge is rarely needed in every day's life, it is nevertheless important. The character which are in the input document are nothing but hcaracters at first. Even the characters known to have a special meaning like '%', '\' or the braces '{}' are *not* special -- until they have been converted to a token. This happens when TeX encounters them the first time during its linear processing of the character stream. A token stays a token and it will remain the same token forever. If you manage to tell TeX that '\' is a normal character and TeX sees just one backslash, this backslash will be a normal character token -- even if the meaning of all following backslashes is again special.

```admonish
もうひとつは、TeXが文字を見る前に知っておくべきことだ。この知識は日常生活で必要になることはほとんどないが、それでも重要である。入力文書にある文字は、最初はただの文字である。'%'や'˶'や中括弧'{}'のような特別な意味を持つことが知られている文字でも、トークンに変換されるまでは特別な文字ではありません。これは、TeXが文字ストリームの線形処理中に初めてこれらの文字に出会ったときに起こります。トークンはトークンのままで、永遠に同じトークンのままです。もし'˶'が通常の文字であることをTeXに伝えることができ、TeXがバックスラッシュを1つだけ見た場合、このバックスラッシュは通常の文字トークンになります。
```

Now, we are given a very long list of tokens `<token1><token2><token3><token4><token5>...`. TeX processes these tokens one-by-one in linear sequence. If `<token1>` is a character token like 'a', it is typeset. This is not what I want to write about here now; my main point is how to program in TeX. So, the interesting thing in these notes is when `<token1>` is a macro.

```admonish
ここで、非常に長いトークンのリスト `<token1><token2><token3><token4><token5>...` が与えられます。TeXはこれらのトークンを1つずつ線形に処理します。もし`<token1>`が'a'のような文字トークンであれば、タイプセットされます。今ここで書きたいのはこのことではなく、私の本題はTeXでどのようにプログラミングするかということだ。つまり、このメモで興味深いのは `<token1>` がマクロである場合である。
```

### 2.3.1 Macros

We have already seen some application of macros above. Actually, most uses who are willing to read notes about TeX programming will have seen macros and may have written some on their own -- for example using `\newcommand` (`\newcommand` is a "more high-level" version of `\def` used only in LaTeX).

```admonish
上でマクロの応用例をいくつか見てきた。実際、TeXプログラミングに関するノートを読もうとするほとんどのユーザーはマクロを見たことがあるだろうし、例えば `newcommand` を使って自分でいくつか書いたことがあるかもしれない（`newcommand` は LaTeX でのみ使用される `def` の「より高レベルな」バージョンである）。
```

A macro has a name and is treated as an elementary token in TeX (even if the name is very long). A macro has replacement text. As soon as TeX encounters a macro, it replaces its occurrence with he replacement text. Furthermore, a macro can consume one or more of the following tokens as arguments.

```admonish
マクロは名前を持ち、TeXでは（名前が非常に長くても）エレメンタリー・トークンとして扱われます。マクロは置換テキストを持ちます。TeXはマクロに出会うとすぐに、その出現箇所を置換テキストで置き換えます。さらに、マクロは以下のトークンを1つ以上引数として受け取ることができます。
```

`\def<\macroname><argument pattern>{<replacement text>}`

A new macro named `<macroname>` will be defined (or re-defined). THe `{<replacement text>}` is the macro body, whenever the macro is executed, it expands to `{<replacement text>}`. The `{<replacement text>}` is a token list which can contain other macros. On the time of the definition, TeX does *not* process (expand) the `{<replacement text>}`.

```admonish
`{<マクロ名>`という新しいマクロが定義されます(または再定義されます)。<replacement text>}` はマクロ本体で、マクロが実行されるたびに `{<replacement text>}` に展開されます。`{<置換テキスト>}`はトークンリストで、他のマクロを含めることができます。定義した時点では、TeXは `{<replacement text>}` を処理（展開）しません。
```

The `{<replacement text>}` will only be expanded if the macro is executed. This does also apply to any macros which are inside of `{<replacement text>}`.

```admonish
`{<置換テキスト>}`はマクロが実行された場合のみ展開されます。これは `{<置換テキスト>}` の中にあるマクロにも適用されます。
```

Macros can be defined almost everywhere in a TeX socument. They can also be invoked almost everywhere.

```admonish
マクロはTeX文書のほとんどあらゆる場所で定義できます。また、ほとんどすべての場所で呼び出すことができます。
```

The `<argument pattern>` is a token list which can contain simple strings or macro parameters `#<number>` or other macro tokens. The `<number>` of the first parameter is always 1, the second must have 2 and so on up to at most 9. Valid argument patterns are `#1#2#3`, `(#1,#2,#3)` or `--\relax`. If TeX executes a macro, it searches for `<argument pattern>` in the input token list until the first match is found. It no match can be found, it aborts with a (more or less helpful) error message.

```admonish
<argument pattern>` はトークン・リストで、単純な文字列かマクロ・パラメータ `#<number>` や他のマクロ・トークンを含むことができます。最初のパラメータの `<number>` は常に 1 で、2 番目のパラメータは 2 で、最大 9 まで指定できます。有効な引数のパターンは `#1#2#3`, `(#1,#2,#3)` または `--relax` である。TeXがマクロを実行する場合、入力トークン一覧から `<引数パターン>` を最初にマッチするまで検索します。マッチするものが見つからなかった場合、(多かれ少なかれ役に立つ) エラーメッセージを表示して終了します。
```

`\expandafter<token><next token>`

The `\expandafter` command is an -- at first sight confusing -- method to alter the input token list. But: it solves our problem with `\point\temp`


`\edef<\macroname><argument pattern>{<replacement text>}`

The `\edef` command is the same as `\def` insofar as it defines a new macro. However, it expands `{<replacement text>}` until only unexpeandable tokens remain (`\edef` = expanded definition)

```latex
\def\a{3}
\def\b{2\a}
\def\c{1\b}
\def\d{value=\c}
\message{Macro `d' is defined to be `\meaning\d'}
\edef\d{value=\c}
\message{Macro `d' is e-defined to be `\meaning\d'}
\expandafter\def\expandafter\d\expandafter{\c}
\message{Macro `d' is defined to be `\meaning\d' using expandafter}
```

`\noexpnd<expandable token>`

The `\noexpand` command is only useful inside of the `{<replacement text>}` of an `\edef` command. As soon as `\edef` encounters the `\noexpand`, the `\noexpand` wil be removed nad the `<expandable token>` will be converted into an unexpandable token. Thus, the code

```latex
\edef\d{Invoke \noexpand\a another macro}
\message{Macro `d' is defined to be `\meaning\d'}
```

yields the terminal output

  Macro `d' is defined to be `macro:->Invoke \a another macro'

because `\noexpand\a` yields the token `\a` (unexpanded).

`\csname<expandable tokens>\endcsname`

This command is not a macro definition, it is a definition of a macro's name. The "cs" means "control sequence". The `\csname`, `\endcsname` pair defines a control sequence name (a macro name) using `<expnadable tokens>`. THe control sequence character '\' will be prepended automatically by `\csname`.

  This here is normal usage: `Content'.
  This here uses csname: `Content'.

```latex
\def\macro{Content}
This here is normal usage: `\macro'.
This here uses csname: `\csname macro\endcsname'.
```

## 3  Survey of Key-Value Handling using pgfKeys

One of the most important things for every TeX package is key-value input. There is a good overview and survey over different key-value packages, among them `xkeyval` and `pgfkeys`, in [5].

```admonish
すべてのTeXパッケージにとって最も重要なものの1つはキー・バリュー入力である。xkeyval`や`pgfkeys`など、さまざまなkey-valueパッケージの概要とサーベイが[5]にあります。
```

In addition to the paper mentioned above and the extensive reference manual for `pgfkeys` in [4], I give a brief survey over `pgfkeys` here. The addressed audience is primarily package writers or macro programmers. This section should allow you to define your own user interfaces and styles for `PGFPLOTS` and for PGF. It should also improve the understanding of `pgfkeys` and how it is to be used. I also address the topic of key filtering which is mainly useful for package writers.

```admonish
上記の論文と[4]にある`pgfkeys`の広範なリファレンスマニュアルに加えて、ここでは`pgfkeys`について簡単なサーベイを行う。対象読者は主にパッケージ作成者やマクロプログラマである。このセクションを読めば、 `PGFPLOTS` や PGF に対して、独自のユーザーインターフェースやスタイルを定義できるようになるはずです。また、`pgfkeys`とその使用方法についての理解も深まるはずです。また、主にパッケージ作成者に役立つキーフィルタリングの話題も扱います。
```

The package `pgfkeys` is available as stand-alone package `\usepackage{pgfkeys}`. However, I believe that you never need to load it explicitly as PGF wlil be loaded anyway and PGF always loads `pgfkeys`.

```admonish
pgfkeys`パッケージは、スタンドアロンパッケージ `usepackage{pgfkeys}` として利用可能です。しかし、PGFはどのみちロードされるし、PGFは常に `pgfkeys` をロードするので、明示的にロードする必要はないと思います。
```

It comes with two user interfaces. I believe that is it sa best-practice to use the best of both worlds; although it might be sufficient to use just one of them. Consequently, I discuss both of them and propsoe a best-practice afterwards.

```admonish
2つのユーザーインターフェイスが搭載されている。どちらか片方だけでも十分かもしれないが、私は両方の長所を使うのがベストプラクティスだと考えている。しかし、どちらか片方だけでも十分かもしれません。そのため、その両方について説明し、ベストプラクティスを提案します。
```

### 3.1 The Low-Level (Direct) Api of pgfKeys

Let us start with the low-level API of `PGFKEYS`. It consists of a couple of macros which allow to define keys, assign values, and get their values back.

```admonish
まずは `PGFKEYS` の低レベルAPIから見ていこう。これはキーを定義し、値を代入し、その値を返すことができるいくつかのマクロから構成されている。
```

`pgfkeyssetvalue{</key path/key name>}{<value>}`

This macro (re)defines a key. It is (almost) equivalent to a macro definition of sorts.

```admonish
このマクロはキーを（再）定義する。ある種のマクロ定義と（ほぼ）等価である。
```

```latex
\expandafter\def\csname key@</key path/key name>\endcsname{<value>};
```

The `<value>` can be anything; it is just stored. It can even contain `#`.

```admonish
`<値>`は何でもよく、ただ格納されるだけである。保存されるだけである。
```

`pgfkeysgetvalue{</key path/key name>}{<\macro>}`

As you might have guessed, this macro allows to retrieve the value for some key and store it into `<\macro>`.
No that we have read about `\pgfkeyssetvalue` and `\pgfkeysgetvalue`, we can also provide an example.

```admonish
お察しの通り、このマクロはあるキーの値を取得して `<macro>` に格納することができる。
```

  The value of key /notes/key is `abc'.

```latex
\pgfkeyssetvalue{/notes/key}{abc}
\pgfkeysgetvalue{/notes/key}\temp
The value of key \texttt{/notes/key} is `\temp'.
```

There is few magic around these two keys; it is just like a hashmap access with some special naming converntion for the keys (due to the key path). Note that since "hashmap access" is what TeX does lal the time when it handles macros, we could have replced the pair `\pgfkeyssetvalue`/`\pgfkeysgetvalue` by `\def` and suitable `\let` commands, perhaps combined with `\csname...\endcsname`. The advantage of PGFKeys comes into play as soon as we inspect the high-level user interface in the next section.

```admonish
この2つのキーの周りにはマジックはほとんどありません。（キーパスによる）キーの特別な名前変換を伴うハッシュマップアクセスのようなものです。ハッシュマップアクセス」はTeXがマクロを処理するときに常に行うことなので、 `pgfkeyssetvalue`/`pgfkeysgetvalue`のペアを`def`コマンドと適切な `let`コマンドで置き換えることができました。PGFKeysの利点は、次のセクションで高レベルのユーザインタフェースを調べるとすぐ に発揮される。
```

Note that since `\pgfkeyssetvalue` is essentially the same as a suitable `\def`, the assignment is local to the current TeX group. In other words: the assignment will be undone by the next closing curly brace, or the next `\endgroup`, or the next `\end<environment>}`.

```admonish
pgfkeysetvalue`は適切な`def`と本質的に同じなので、代入は現在のTeXグループに対してローカルであることに注意してください。言い換えると、この代入は次の閉じ中括弧か、次の `endgroup` か、次の `end<environment>}` で元に戻される。
```

`pgfkeyslet{</key path/key name>}{<\macro>}`

This is essentially the same as `\pgfkeyssetvalue`, except that the key's value is already available inside of `{<macro>}`:

```admonish
これは基本的に `pgfkeyssetvalue` と同じであるが、キーの値が `{<macro>}` の中で既に利用可能である点が異なる：
```

  The value of key /notes/key is `abc'.

```latex
\def\something{abc}
\pgfkeyslet{/notes/key}{\something}
\pgfkeysgetvalue{/notes/key}\temp
The value of key \texttt{/notes/key} is `\temp'.
```

Just like `\pgfkeyssetvalue` boils down to `\def`, `\pgfkeyslet` boils down to `\let`.

```admonish
pgfkeysetvalue`が`def`に集約されるように、`pgfkeyslet`が`let`に集約される。
```

`\pgfkeysvalueof{</key path/key name>}`

This is essentially the same as `\pgfkeysgetvalue{</key path/key name>}{<\macro>} <\macro>`; i.e. it expands to the value stred in a key.

```admonish
これは基本的に `pgfkeysgetvalue{</key path/key name>}{<macro>} <\macro>` と同じである。
```

  The value of key /notes/key is `abc'.

```latex
\pgfkeyssetvalue{/notes/key}{abc}
The value of key \texttt{/notes/key} is `\pgfkeysvalueof{/notes/key}'.
```

However, this key has one major advantage: it can be used inside of an `\edef` (because it is fully expandable):

```admonish
しかし、このキーには一つの大きな利点がある。それは、`edef` の中で使えることである（完全に拡張可能だから）：
```

  The value of key /notes/key along with dashes is | abc |.

```latex
\pgfkeyssetvalue{/notes/key}{abc}
\edef\temp{--- \pgfkeysvalueof{/notes/key} ---}
The value of key \texttt{/notes/key} along with dashes is \temp.
```

It boils down to a suitable `\csname ... \endcsname`. Consequently, it expands to `\relax` if the key happens to undefined. (see `\pgfkeysifdefined` below).

```admonish
それは適切な`csname ....\endcsname`となる。その結果、キーが未定義になると `relax` に展開される。(下記の `pgfkeysifdefined` を参照）。
```

`\pgfkeysdef{</key path/key name>}{<macro body>}`

This is a variant of `\pgfkeyssetvalue`. However, it has a substantial difference which appears to be unmotivated as long as we discuss the low-level API. It defines a so-called code-key.

```admonish
これは `pgfkeyssetvalue` の亜種である。しかし、低レベルのAPIを議論する限り、あまり意味がないように見える大きな違いがある。これはいわゆるコードキーを定義する。
```

Code-keys are executable macros. They take an argument, and they do something iwith it. "Assigning values" to such a key is equivalent to invoking `<macro body>` in a "suitable" way.

```admonish
コードキーは実行可能なマクロである。引数を取り、その引数で何かを行う。このようなキーに "値を割り当てる "ことは、`<マクロ本体>`を "適切な "方法で呼び出すことと同じである。
```

The result of this macro call is a new key named `</key path/key name/>.@cmd`. That key, in turn, is stored as executable macro. The macro is equivalent to the following definition (up to the name, of course):

```admonish
このマクロ呼び出しの結果は、`</key path/key name/>.@cmd` という新しいキーになる。このキーは実行可能なマクロとして保存されます。このマクロは以下の定義と等価である（もちろん名前まで）：
```

```latex
\def\macro#1\pgfeov{<macro body>}
```

This macro is stored (using `\pgfkeyslet`) under `</key path/key name/.@cmd`.
We can use `\pgfkeysgetvalue` and/or `\pgfkeysvalueof` to access this special key, even though its use becomes more apparent later in this document:

```admonish
このマクロは、（`pgfkeyslet`を使用して）`</key path/key name/.@cmd` の下に格納される。 この特別なキーにアクセスするために、`pgfkeysgetvalue` や `pgfkeysvalueof` を使用することができる：
```

  We \assign a value" or \execute the code key" (which is equivalent):
  Expansion with value abc|X.

```latex
\pgfkeysdef{/notes/code key}{Expansion with value #1---X.}%
We ``assign a value'' or ``execute the code key'' (which is equivalent):
\pgfkeysvalueof{/notes/code key/.@cmd}abc\pgfeov
```

Note that in this scase, we *have* to use `\pgfeov` to terminate the argument list. We could have placed our argument into curly braces, bet we have to provide `\pgfeov`; just as we had to add the suffix `/.@cmd`.

```admonish
このケースでは、引数リストを終了するために `ppgfeov` を使わなければならないことに注意してほしい。引数を中カッコで囲むこともできたが、`/.@cmd`という接尾辞をつけなければならなかったように、`pgfeov`をつけなければならない。
```

`\pgfkeysifdefined{</key path/key name>}{<true case>}{<false case>}`
`\pgfkeysifassignable{</key path/key name>}{<true case>}{<false case>}`

These keys provide conditionals based on existence or type of a key. Please refer to the reference manual in [4] for details.

```admonish
これらのキーは、キーの存在またはタイプに基づく条件分岐を提供する。詳細は[4]のリファレンス・マニュアルを参照されたい。
```

## 3.2  The Standard Api of the pgfKeys

Now that we have seen how things defined by PGFKeys can be accessed at a rather low level of abstraction, we will repeat the same using a higher level. This section  explains the standard API of PGFKeys; this is how Keys can be defined and maintained easily, and it is also the end user interface.

```admonish
さて、PGFKey で定義されたものが、どのように抽象度の低いレベルでアクセスできるかを見てきました。この節では、PGFKeysの標準APIについて説明します。このAPIは、どのようにキーを定義し、簡単に維持することができるかということであり、また、エンドユーザーインターフェイスでもあります。
```

PGFKeys addresses a couple of use-cases with its standard API:

1. simple key-value storage (i.e. put and get),
1. code-keys which can do some (complex) operation whenever the key is used
1. configuration and modification of the key-value tool.

```admonish
PGFKeysは、その標準APIでいくつかのユースケースに対応しています：

1. 単純なキー・バリュー・ストレージ（すなわち、putとget）、
1. キーが使用されるたびに何らかの（複雑な）操作を行うことができるコード・キー、
1. キー・バリュー・ツールの設定と変更。
```

All of these items are possible with the same macro:

```admonish
これらの項目はすべて同じマクロで可能だ：
```

`\pgfkeys{<common-separated key-value pairs>}`

This key constitudes the public API of PGFKeys. It accepts any number of key-value pairs, separated by commas.

```admonish
このキーは、PGFKeysのパブリックAPIを定常化します。カンマで区切られた任意の数のキーと値のペアを受け付けます。
```
