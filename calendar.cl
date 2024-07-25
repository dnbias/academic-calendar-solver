% clingo src file
% an academic calendar solver

week(1..1).
day(mon;tue;wed;thu;fri;sat).
hour(1..8).
hours(W,D,0):-week(W), not fulltime(W), day(D), D!=fri, D!=sat.
hours(W,D,8):-week(W), fulltime(W), day(D), D!=fri, D!=sat.
hours(W,fri,8):-week(W).
hours(W,sat,6):-week(W).
fulltime(2).

teacher(muzzetto;pozzato;gena;tomatis;micalizio).
subject(pres;free;pm;fictpp;lm;gq;aslcweb).
hoursOf(free,2;pm,2;fictpp,2;lm,2;gq,2;aslcweb,2).
hoursCount(S,N):- subject(S), N = #count { W,D,H,S: assign(W,D,H,S), subject(S) }.

teaching(muzzetto,pm).
teaching(pozzato,fictpp).
teaching(gena,lm).
teaching(tomatis,gq).
teaching(micalizio,aslcweb).

assign(1,fri,1,pres).
assign(1,fri,2,pres).

% assign each slot a subject
1 { assign(W,D,H,S): subject(S) } 1:-week(W),day(D),hour(H),
                                     hours(W,D,N), H<=N.

% 2h slots
:-assign(W,D,H,S), assign(W,D,H+1,S1), H\2==1, S!=S1.
% max 2 slots per teacher per day
:-assign(W,D,H,S), assign(W,D,H1,S1), assign(W,D,H2,S2),
  teaching(T,S), teaching(T,S1), teaching(T,S2),
  H!=H1,H!=H2,H1!=H2, H\2==1, H1\2==1, H2\2==1.
% max 2 slots per subject per day
:-assign(W,D,H,S), assign(W,D,H1,S1), assign(W,D,H2,S2),
  S==S1,S==S2,S1==S2,
  H!=H1,H!=H2,H1!=H2, H\2==1, H1\2==1, H2\2==1.
% hours of teaching must be fullfilled
:-hoursCount(S,N), hoursOf(S,N1), N!=N1.

#show assign/4.
#show hoursCount/2.
