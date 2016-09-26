/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
____            ____
\   \          /   /
 \   \  ____  /   /
  \   \/    \/   /
   \     /\     /     BRACHYLOG       
    \   /  \   /      A terse declarative logic programming language
    /   \  /   \    
   /     \/     \     Written by Julien Cumin - 2016
  /   /\____/\   \    https://github.com/JCumin/Brachylog
 /   /  ___   \   \
/___/  /__/    \___\
     
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


:- module(constraint_predicates, [brachylog_constraint_different/2,
                                  brachylog_constraint_even/2,
                                  brachylog_constraint_odd/2,
                                  brachylog_constraint_prime/2,
                                  brachylog_constraint_all_equal/2,
                                  brachylog_constraint_coerce_to_integer/2,
                                  brachylog_constraint_coerce_to_string/2,
                                  brachylog_constraint_coerce_to_list/2,
                                  brachylog_constraint_positive/2,
                                  brachylog_constraint_negative/2,
                                  brachylog_constraint_strictly_positive/2,
                                  brachylog_constraint_strictly_negative/2,
                                  brachylog_constraint_digit/2,
                                  brachylog_constraint_nonzero_digit/2
                                 ]).
                       
:- use_module(library(clpfd)).
:- use_module(utils).

:- multifile clpfd:run_propagator/2.


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_DIFFERENT
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_different([],[]).
brachylog_constraint_different([H|T],[H|T]) :-
    maplist(prepend_integer,L,[H|T]),
    all_distinct(L).
brachylog_constraint_different('integer':0,'integer':0).
brachylog_constraint_different('integer':I,'integer':I) :-
    H #\= 0,
    integer_value('integer':_:[H|T],I),
    all_distinct([H|T]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_EVEN
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_even('integer':I,'integer':I) :-
    I mod 2 #= 0.
brachylog_constraint_even([H|T],[H|T]) :-
    maplist(brachylog_constraint_even,[H|T],[H|T]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_ODD
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_odd('integer':I,'integer':I) :-
    I mod 2 #= 1.
brachylog_constraint_odd([H|T],[H|T]) :-
    maplist(brachylog_constraint_odd,[H|T],[H|T]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_PRIME
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_prime('integer':N,'integer':N) :-
    clpfd:make_propagator(prime(N), Prop),
    clpfd:init_propagator(N, Prop),
    clpfd:trigger_once(Prop).

clpfd:run_propagator(prime(N), MState) :-
    (
        nonvar(N) -> clpfd:kill(MState), check_prime(N)
        ;
        clpfd:fd_get(N,ND,NL,NU,NPs),
        clpfd:cis_max(NL,n(2),NNL),
        clpfd:update_bounds(N,ND,NPs,NL,NU,NNL,NU)
    ).

check_prime(N) :-
    N #= 2 -> true
    ;
    N #> 2,
    ceiled_square_root(N,SN),
    check_prime_1(N, SN, 2, [], [_]).

check_prime_1(1, _, _, L, L) :- !.
check_prime_1(N, SN, D, L, LF) :-
    (   
        0 #= N mod D -> false
        ;
        D1 #= D+1,
        (    
            D1 #> SN ->
            LF = [N |L]
            ;
            check_prime_2(N, SN, D1, L, LF)
        )
    ).

check_prime_2(1, _, _, L, L) :- !.
check_prime_2(N, SN, D, L, LF) :-
    (   
        0 #= N mod D -> false
        ;
        D1 #= D+2,
        (    
            D1 #> SN ->
            LF = [N |L]
            ;
            check_prime_2(N, SN, D1, L, LF)
        )
    ).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_ALL_EQUAL
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_all_equal([],[]).
brachylog_constraint_all_equal([H|T],[H|T]) :-
    maplist(=(H),T).
brachylog_constraint_all_equal('string':L,'string':L) :-
    brachylog_constraint_all_equal(L,L).
brachylog_constraint_all_equal('integer':0,'integer':0).
brachylog_constraint_all_equal('integer':I,'integer':I) :-
    H #\= 0,
    integer_value('integer':_:[H|T],I),
    brachylog_constraint_all_equal([H|T],[H|T]).
 
 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_COERCE_TO_INTEGER
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_coerce_to_integer('integer':I,'integer':I).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_COERCE_TO_STRING
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_coerce_to_string('string':S,'string':S).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_COERCE_TO_LIST
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_coerce_to_list([],[]).
brachylog_constraint_coerce_to_list([H|T],[H|T]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_POSITIVE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_positive('integer':I,'integer':I) :-
    I #>= 0.
brachylog_constraint_positive([H|T],[H|T]) :-
    maplist(brachylog_constraint_positive,[H|T],[H|T]).
    

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_NEGATIVE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_negative('integer':I,'integer':I) :-
    I #=< 0.
brachylog_constraint_negative([H|T],[H|T]) :-
    maplist(brachylog_constraint_negative,[H|T],[H|T]).


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_STRICTLY_POSITIVE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_strictly_positive('integer':I,'integer':I) :-
    I #> 0.
brachylog_constraint_strictly_positive([H|T],[H|T]) :-
    maplist(brachylog_constraint_strictly_positive,[H|T],[H|T]).
    

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_STRICTLY_NEGATIVE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_strictly_negative('integer':I,'integer':I) :-
    I #< 0.
brachylog_constraint_strictly_negative([H|T],[H|T]) :-
    maplist(brachylog_constraint_strictly_negative,[H|T],[H|T]).
    
    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_DIGIT
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_digit('integer':I,'integer':I) :-
    I in 0..9.
brachylog_constraint_digit([H|T],[H|T]) :-
    maplist(brachylog_constraint_digit,[H|T],[H|T]).
    
    
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   BRACHYLOG_CONSTRAINT_NONZERO_DIGIT
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
brachylog_constraint_nonzero_digit('integer':I,'integer':I) :-
    I in 1..9.
brachylog_constraint_nonzero_digit([H|T],[H|T]) :-
    maplist(brachylog_constraint_nonzero_digit,[H|T],[H|T]).
