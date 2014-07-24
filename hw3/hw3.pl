transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
    lists_firsts_rests(Ms, Ts, Ms1),
    transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

kenken2(_,[]).
kenken2(N,[L|Lx]):-
	length(L,N),
	fd_domain(L,1,N),
	fd_all_different(L),
	fd_labeling(L),
	kenken2(N, Lx).

kenken1(_,[]).
kenken1(N,[L|Lx]):-
	length(L,N),
	fd_all_different(L),
	kenken1(N, Lx).


cons([],_,_).
cons([C|Cr],L,N):-
	constraint(C,L,N),
	cons(Cr,L,N).

constraint(C,L,N):-
	C = +(G, Coodlist),
	add(G, 0, Coodlist, L,N).
constraint(C,L,N):-
	C = -(G, Cood1, Cood2),
	minus(G, Cood1, Cood2, L,N).
constraint(C,L,N):-
	C = *(G, Coodlist),
	time(G, 1, Coodlist, L,N).
constraint(C,L,N):-
	C = /(G, Cood1, Cood2),
	devide(G, Cood1, Cood2, L,N).

add(G,V,[],_,_):- G =:= V.
add(G,V,[Cood1|Coodr], L,N):-
	Cood1 = X-Y,
	nth(X, L, R),
	nth(Y, R, E),
	fd_domain(E,1,N),
	fd_labeling(E),
	V1 is V + E,
	add(G,V1,Coodr,L,N).

time(G,V,[],_,_):- G =:= V.
time(G,V,[Cood1|Coodr],L,N):-
	Cood1 = X-Y,
	nth(X, L, R),
	nth(Y, R, E),
	fd_domain(E,1,N),
	fd_labeling(E),
	V1 is V*E,
	time(G,V1,Coodr,L,N).

minus(G, Cood1, Cood2, L,N):-
	Cood1 = X1-Y1,
	nth(X1, L, R1),
	nth(Y1, R1, E1),
	fd_domain(E1,1,N),
	fd_labeling(E1),
	Cood2 = X2-Y2,
	nth(X2, L, R2),
	nth(Y2, R2, E2),
	fd_domain(E2,1,N),
	fd_labeling(E2),
	checkminus(G,E1,E2).
checkminus(G,E1,E2):- G =:= E1-E2.
checkminus(G,E1,E2):- G =:= E2-E1.

devide(G, Cood1, Cood2, L,N):-
	Cood1 = X1-Y1,
	nth(X1, L, R1),
	nth(Y1, R1, E1),
	fd_domain(E1,1,N),
	fd_labeling(E1),
	Cood2 = X2-Y2,
	nth(X2, L, R2),
	nth(Y2, R2, E2),
	fd_domain(E2,1,N),
	fd_labeling(E2),
	checkdevide(G,E1,E2).
checkdevide(G,E1,E2):- G =:= E1/E2.
checkdevide(G,E1,E2):- G =:= E2/E1.

kenken(N, [], L):-
	length(L,N),
	kenken2(N,L),
	transpose(L, Lt),
	kenken2(N,Lt).

kenken(N, C, L):-
	C \= [],
	length(L,N),
	kenken1(N,L),
	transpose(L, Lt),
	kenken1(N,Lt),
	cons(C, L,N).


alldifferent([]).
alldifferent([H|T]):-
    \+(member(H,T)),
    alldifferent(T).

checkmatrix([]).
checkmatrix([L|Lx]):-
	alldifferent(L),
	checkmatrix(Lx).

buildlist(1,L):-	L = [1].
buildlist(N,L):-
	N > 1,
	N1 is N - 1,
	buildlist(N1, Lx),
	append(Lx, [N], L).

matrix(_,[]).
matrix(N, [L|Lx]):-
	buildlist(N,Temp),
	permutation(Temp,L),
	matrix(N, Lx).

plain_kenken(N, C, L):-
	length(L,N),
	matrix(N,L),
	transpose(L, Lt),
	checkmatrix(Lt),
	p_cons(C, L).

p_cons([],_).
p_cons([C|Cr],L):-
	p_constraint(C,L),
	p_cons(Cr,L).

p_constraint(C,L):-
	C = +(G, Coodlist),
	p_add(G, 0, Coodlist, L).
p_constraint(C,L):-
	C = -(G, Cood1, Cood2),
	p_minus(G, Cood1, Cood2, L).
p_constraint(C,L):-
	C = *(G, Coodlist),
	p_time(G, 1, Coodlist, L).
p_constraint(C,L):-
	C = /(G, Cood1, Cood2),
	p_devide(G, Cood1, Cood2, L).

p_add(G,V,[],_):- G =:= V.
p_add(G,V,[Cood1|Coodr], L):-
	Cood1 = X-Y,
	nth(X, L, R),
	nth(Y, R, E),
	V1 is V + E,
	p_add(G,V1,Coodr,L).

p_time(G,V,[],_):- G =:= V.
p_time(G,V,[Cood1|Coodr],L):-
	Cood1 = X-Y,
	nth(X, L, R),
	nth(Y, R, E),
	V1 is V*E,
	p_time(G,V1,Coodr,L).

p_minus(G, Cood1, Cood2, L):-
	Cood1 = X1-Y1,
	nth(X1, L, R1),
	nth(Y1, R1, E1),
	Cood2 = X2-Y2,
	nth(X2, L, R2),
	nth(Y2, R2, E2),
	checkminus(G,E1,E2).

p_devide(G, Cood1, Cood2, L):-
	Cood1 = X1-Y1,
	nth(X1, L, R1),
	nth(Y1, R1, E1),
	Cood2 = X2-Y2,
	nth(X2, L, R2),
	nth(Y2, R2, E2),
	checkdevide(G,E1,E2).

kenken_testcase(
  6,
  [
   +(11, [1-1, 2-1]),
   /(2, 1-2, 1-3),
   *(20, [1-4, 2-4]),
   *(6, [1-5, 1-6, 2-6, 3-6]),
   -(3, 2-2, 2-3),
   /(3, 2-5, 3-5),
   *(240, [3-1, 3-2, 4-1, 4-2]),
   *(6, [3-3, 3-4]),
   *(6, [4-3, 5-3]),
   +(7, [4-4, 5-4, 5-5]),
   *(30, [4-5, 4-6]),
   *(6, [5-1, 5-2]),
   +(9, [5-6, 6-6]),
   +(8, [6-1, 6-2, 6-3]),
   /(2, 6-4, 6-5)
  ]
).
