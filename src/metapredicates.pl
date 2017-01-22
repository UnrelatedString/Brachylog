/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
____            ____
\   \          /   /
 \   \  ____  /   /
  \   \/    \/   /
   \     /\     /     BRACHYLOG       
    \   /  \   /      A terse declarative logic programming language
    /   \  /   \    
   /     \/     \     Written by Julien Cumin - 2017
  /   /\____/\   \    https://github.com/JCumin/Brachylog
 /   /  ___   \   \
/___/  /__/    \___\
     
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


:- module(metapredicates, [brachylog_meta_find/5,
                           brachylog_meta_iterate/5,
                           brachylog_meta_map/5
                          ]).

:- use_module(library(clpfd)).
    
    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_META_FIND
   
   Credits to @false for call_firstf/2 and call_nth/2
   http://stackoverflow.com/a/20866206/2554145
   http://stackoverflow.com/a/11400256/2554145
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_meta_find('first', P, Sub, ['integer':I|Input], Output) :- 
    (   Input = [Arg] -> true
    ;   Input = Arg
    ),
    brachylog_meta_find('integer':I, P, Sub, Arg, Output).
brachylog_meta_find('last', P, Sub, Input, Output) :-
    reverse(Input, ['integer':I|T]),
    (   T = [Arg] -> true
    ;   T = Arg
    ),
    brachylog_meta_find('integer':I, P, Sub, Arg, Output).
brachylog_meta_find('integer':0, _, _, _, []).
brachylog_meta_find('default', P, Sub, Input, Output) :-
    findall(X, call(P, Sub, Input, X), Output).
brachylog_meta_find('integer':I, P, Sub, Input, Output) :-
    I #> 0,
    findall(X, call_firstn(call(P, Sub, Input, X), I), Output).

call_firstn(Goal_0, N) :-
    N + N mod 1 >= 0,         % ensures that N >=0 and N is an integer
    call_nth(Goal_0, Nth),
    ( Nth == N -> ! ; true ).

call_nth(Goal_0, C) :-
    State = count(0, _),
    Goal_0,
    arg(1, State, C1),
    C2 is C1+1,
    nb_setarg(1, State, C2),
    C = C2.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_META_ITERATE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_meta_iterate('first', P, Sub, ['integer':I|Input], Output) :-
    (   Input = [Arg] -> true
    ;   Input = Arg
    ),
    brachylog_meta_iterate(I, P, Sub, Arg, Output).
brachylog_meta_iterate('last', P, Sub, Input, Output) :-
    reverse(Input, ['integer':I|T]),
    (   T = [Arg] -> true
    ;   T = Arg
    ),
    brachylog_meta_iterate(I, P, Sub, Arg, Output).
brachylog_meta_iterate('integer':0, _, _, Input, Input).
brachylog_meta_iterate('default', P, Sub, Input, Output) :-
    brachylog_meta_iterate('integer':1, P, Sub, Input, Output).
brachylog_meta_iterate('integer':1, P, Sub, Input, Output) :-
    call(P, Sub, Input, Output).
brachylog_meta_iterate('integer':I, P, Sub, Input, Output) :-
    I #> 1,
    call(P, Sub, Input, TOutput),
    J #= I - 1,
    brachylog_meta_iterate('integer':J, P, Sub, TOutput, Output).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_META_MAP
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_meta_map('first', P, Sub, ['integer':I|Input], Output) :-
    (   Input = [Arg] -> true
    ;   Input = Arg
    ),
    brachylog_meta_map('integer':I, P, Sub, Arg, Output).
brachylog_meta_map('last', P, Sub, Input, Output) :-
    reverse(Input, ['integer':I|T]),
    (   T = [Arg] -> true
    ;   T = Arg
    ),
    brachylog_meta_map('integer':I, P, Sub, Arg, Output).
brachylog_meta_map('integer':0, P, Sub, Input, Output) :-
    call(P, Sub, Input, Output).
brachylog_meta_map('default', P, Sub, Input, Output) :-
    brachylog_meta_map('integer':1, P, Sub, Input, Output).
brachylog_meta_map('integer':1, P, Sub, Input, Output) :-
    Pred =.. [P, Sub],
    maplist(Pred, Input, Output).
brachylog_meta_map('integer':I, P, Sub, Input, Output) :-
    I #> 1,
    J #= I - 1,
    maplist(brachylog_meta_map('integer':J, P, Sub), Input, Output).