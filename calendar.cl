% clingo src file
% an academic calendar solver

week(1..16).
day(mon;tue;wed;thu;fri;sat).
hour(1..8).
fulltime(7).
fulltime(16).
hours(W,D,0):-week(W), not fulltime(W), day(D), D!=fri, D!=sat.
hours(W,D,8):-week(W), fulltime(W), day(D), D!=fri, D!=sat.
hours(W,fri,8):-week(W).
hours(W,sat,6):-week(W).

teacher(muzzetto;pozzato;gena;tomatis;terranova;mazzei;vargiu;
        giordani;zanchetta;micalizio;boniolo;damiano;suppini;
        valle;ghidelli;gabardi;santangelo;taddeo;gribaudo;
        schifanella;lombardo;travostino).
subject(pres;free;
        pm;fictpp;lm;gq;aslcweb;
        pgdi;pbd;smism;aeisg;aupm;md;efd;
        rdp;tssweb;tsmd;ismm;aes;aesid;cpcp;
        semu;cmasm;g3d;psawm1;psawm2;gru;vgp).

hoursOf(pres,2;free,12;
        pm,14;fictpp,14;lm,20;gq,10;aslcweb,20;
        %% pgdi,10;pbd,20;smism,14;aeisg,14;aupm,14;md,10;efd,10;
        %% rdp,10;tssweb,20;tsmd,10;ismm,14;aes,10;aesid,20;cpcp,14;
        semu,10;cmasm,20;g3d,20;psawm1,10;psawm2,10;gru,10;vgp,10).

hoursCount(S,N):- subject(S), N = #count { W,D,H,S: assign(W,D,H,S), subject(S) } >0.

teaching(muzzetto,pm;muzzetto,md).
teaching(pozzato,fictpp;pozzato,psawm1).
teaching(gena,lm;gena,aupm;gena,aupm).
teaching(tomatis,gq).
teaching(terranova,pgdi).
teaching(mazzei,pbd).
teaching(vargiu,efd).
teaching(giordani,smism).
teaching(zanchetta,aeisg;zanchetta,tsmd).
teaching(micalizio,aslcweb).
teaching(boniolo,rdp).
teaching(damiano,tssweb).
teaching(suppini,ismm).
teaching(valle,eas).
teaching(ghidelli,aesid).
teaching(gabardi,cpcp).
teaching(santangelo,semu).
teaching(taddeo,cmasm).
teaching(gribaudo,g3d).
teaching(schifanella,psawm2).
teaching(lombardo,gru).
teaching(travostino,vgp).

prerequisite(fictpp,aslcweb;aslcweb,psawm1;psawm1,psawm2;
             pbd,tssweb;lm,aslcweb;pm,md;md,tsmd;pm,smism;
             pm,pgdi;aeisg,efd;efd,aesid;aeisg,g3d).

% presentation is first hours of the course
assign(1,fri,1,pres).
assign(1,fri,2,pres).

% assign each slot a subject
1 { assign(W,D,H,S): subject(S) } 1:-week(W),day(D),hour(H),
                                     hours(W,D,N), H<=N.

% 2h slots
:-assign(W,D,H,S), assign(W,D,H+1,S1), H\2==1, S!=S1.
% 4h slots for tssweb
:-S==tssweb, assign(W,D,H,S), assign(W,D,H1,S), assign(W,D,H2,S2),
  H\2==1, H<H1, H2>H1, H2-H==3, S!=S2.
% max 2 slots per teacher per day
:-assign(W,D,H,S), assign(W,D,H1,S1), assign(W,D,H2,S2),
  teaching(T,S), teaching(T,S1), teaching(T,S2),
  H!=H1,H!=H2,H1!=H2, H\2==1, H1\2==1, H2\2==1.
% max 2 slots per subject per day
:-S!=free, assign(W,D,H,S), assign(W,D,H1,S1), assign(W,D,H2,S2),
  S==S1,S==S2,S1==S2,
  H!=H1,H!=H2,H1!=H2, H\2==1, H1\2==1, H2\2==1.
% hours of teaching must be fullfilled
:-S!=free, hoursCount(S,N), hoursOf(S,N1), N!=N1.
:-S==free, hoursCount(S,N), hoursOf(S,N1), N<N1.
% prerequisites must be respected
% last lesson of left-side must precede first lesson of right-side
:-assign(W,D,H,S), assign(W1,D1,H1,S), assign(W2,D2,H2,S1),
  prerequisite(S,S1), W>=W1, D>=D1, H>=H1,
  W2<W, D2<D, H2<H.
% distance between start and end of any teaching cannot exceed 6 weeks SLOW TODO
%% :-assign(W,D,H,S), assign(W1,D1,H1,S),
%%   assign(W2,D2,H2,S), assign(W3,D3,H3,S),
%%   W<=W1, D<=D1, H<=H1, W3>=W2, D3>=D2, H3>=H2, W3-W>=6.
% pm must conclude before 1st fulltime week
:-assign(W,D,H,S), S==pm, fulltime(W1), W>=W1.
% 1st lesson of ismm/cmasm placed in the 2nd fulltime week
:-assign(W,D,H,S), assign(WN,DN,HN,S), S==ismm, W<=WN, D<=DN, H<HN,
  fulltime(W1), fulltime(W2), W1<W2, W!=W2.
:-assign(W,D,H,S), assign(WN,DN,HN,S), S==cmasm, W<=WN, D<=DN, H<HN,
  fulltime(W1), fulltime(W2), W1<W2, W!=W2.
% 1st lesson of aupm before last lesson of lm
:-assign(W,D,H,S), assign(W1,D1,H1,S), S==aupm,
  W<=W1, D<=D1, H<H1,
  assign(W2,D2,H2,S1), assign(W3,D3,H3,S1), S1==lm,
  W3>=W2, D3>=D2, H3>H2,
  W>W3, D>D3, H>=H3.



#show assign/4.
#show hoursCount/2.
