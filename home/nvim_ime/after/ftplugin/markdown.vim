" [Vimでmarkdownの箇条書き](https://zenn.dev/vim_jp/articles/4564e6e5c2866d)
setlocal comments=b:*,b:-,b:+,b:1.,nb:>
setlocal formatoptions-=c formatoptions+=jro
setlocal comments=nb:>
        \ comments+=b:*\ [\ ],b:*\ [x],b:*
        \ comments+=b:+\ [\ ],b:+\ [x],b:+
        \ comments+=b:-\ [\ ],b:-\ [x],b:-
        \ comments+=b:1.\ [\ ],b:1.\ [x],b:1.
        \ formatoptions-=c formatoptions+=jro
