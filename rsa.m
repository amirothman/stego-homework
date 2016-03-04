# TP Maths
# Calcul sur les grands nombres, tests de primalité probabilistes et chiffrement a clef publique RSA
# Copyright (C) 2002 Anthony Ferrand and Guillaume Knispel under GNU GPL license
# http://xilun666.free.fr/octave.m

format long;
global log_base=16
global base=2^log_base

#met un grand nombre sous forme reduite
function nbr=reduc(n)
  s=columns(n);
  while ((s>1) && n(s)==0)
    s--;
  end;
  nbr=n(1:s);
endfunction

#addition de grands nombres
function nbrmax=add(nbr1,nbr2)
global base;
  s1=columns(nbr1);
  s2=columns(nbr2);
  if (s1>=s2)
    nbrmax=nbr1; nbrmin=nbr2;
    maxi=s1; mini=s2;
  else
    nbrmax=nbr2; nbrmin=nbr1;
    maxi=s2; mini=s1;
  end
  nbrmax(1,maxi+1)=0;
  nbrmax(1:mini)=nbrmax(1:mini)+nbrmin;
  for i=1:maxi
    if (nbrmax(i)>=base)
      nbrmax(i)=nbrmax(i)-base;
      nbrmax(i+1)=nbrmax(i+1)+1;
    end
  end
  nbrmax=reduc(nbrmax);
endfunction

#soustraction de grands nombres (retourne résultat positif ou -1 si résultat négatif)
function n1=sub(n1,n2)
global base;
  n1=reduc(n1); n2=reduc(n2);
  s1=columns(n1); s2=columns(n2);
  if s1<s2
    n1=-1;
  else
    n1(s1+1)=0;
    n1(1:s2)=n1(1:s2)-n2;
    for i=1:s1
      if (n1(i)<0)
        n1(i)=n1(i)+base;
        n1(i+1)=n1(i+1)-1;
      end
    end
    if n1(s1+1)==-1
      n1=-1;
    else
      n1=reduc(n1);
    end
  end
endfunction

#multiplication de grands nombres
function nbr=mul(nbr1,nbr2)
global base;
  s1=columns(nbr1); s2=columns(nbr2);
  maxi=s1+s2; nbr=zeros(1,maxi);
  for j=1:s2
     nbr(j:j+s1-1)=nbr(j:j+s1-1)+nbr1*nbr2(j);
  end
  for i=1:maxi-1
    q=floor(nbr(i)/base);
    nbr(i+1)=nbr(i+1)+q;
    nbr(i)=nbr(i)-q*base;
  end
  nbr=reduc(nbr);
endfunction

# division de a par n qui doit etre une puissance de 2 < base
function r=div2(r,n)
  global base;
  sr=columns(r);
  f=floor(r/n);
  c=r-f*n;
  r=f;
  if sr>=2
    r(1:sr-1)=r(1:sr-1)+c(2:sr)*(base/n);
  end
  r=reduc(r);
endfunction;

# division euclidienne de grands nombres
function res=big_div(a,b)
global base;
  a=reduc(a); b=reduc(b);
  sb=columns(b);
  n=1;
  if b(sb)<base/2
    n=2^floor(log2(floor(base/(b(sb)+1))));
#    a=mul(a,n);
    nn=n*a;
    q=floor(nn/base); a=nn-base*q;
    sa=columns(a); a(1,sa+1)=0; a(2:sa+1)=a(2:sa+1)+q;
    a=reduc(a);
#    b=mul(b,n);
    nn=n*b;
    q=floor(nn/base); b=nn-base*q;
    if sb>=2
      b(2:sb)=b(2:sb)+q(1:sb-1);
    end
  end
  sa=columns(a); a(sa+1)=0;

 q=0;
 if sa>=sb
  for i=sa-sb+1:-1:1
    q(1,i)=floor((a(i+sb)*base+a(i+sb-1))/b(sb))+1;

    pr=-1;
    while pr==-1
      q(i)=q(i)-1;
      pr=sub(a(i:i+sb),mul(b,q(i)));
    end
    
    a(i:i+sb)=zeros(1,sb+1);
    a(i:i+columns(pr)-1)=pr;
  end
 end
  
  if n~=1
    a=div2(a,n);
  end

  res.r=reduc(a);
  res.q=reduc(q);
endfunction;

#reste de la division euclidienne de grands nombres
function a=big_reste(a,b)
global base;
  a=reduc(a); b=reduc(b);
  sb=columns(b);
  n=1;
  if b(sb)<base/2
    n=2^floor(log2(floor(base/(b(sb)+1))));
#    a=mul(a,n);
    nn=n*a; q=floor(nn/base); a=nn-base*q;
    sa=columns(a); a(1,sa+1)=0; a(2:sa+1)=a(2:sa+1)+q;
    a=reduc(a);
#    b=mul(b,n);
    nn=n*b; q=floor(nn/base); b=nn-base*q;
    if sb>=2
      b(2:sb)=b(2:sb)+q(1:sb-1);
    end
  end
  sa=columns(a); a(sa+1)=0;

 if sa>=sb
  for i=sa-sb+1:-1:1
    q=floor((a(i+sb)*base+a(i+sb-1))/b(sb));

    pr=-1;
    while pr==-1
      pr=sub(a(i:i+sb),mul(b,q));
      q=q-1;
    end
    
    a(i:i+sb)=zeros(1,sb+1);
    a(i:i+columns(pr)-1)=pr;
  end
 end
  
  if n~=1
    a=div2(a,n);
  else
    a=reduc(a);
  end
endfunction

# calcul y tel que e*y=1(mod m)
function y=inv_mod_big(e,m)
  x=0; y=1;
  a=m; b=e; cpt=0;
  while (columns(b)~=1 || (b~=1))
    rd=big_div(a,b);
    yn=big_reste(add(x,mul(y,rd.q)),m);
    x=y; y=yn;
    a=b; b=rd.r;
    cpt=cpt+1;
  end
  if (rem(cpt,2)==1)
    y=sub(m,y);
  end
endfunction

#exponentiation modulaire de grand nombres (a^n (mod m))
function pm=powmod_big(a,n,m)
  global log_base;
  n=reduc(n);
  bit_q=columns(n);

  pwr=2;
  while (n(bit_q)>=pwr)
    pwr=pwr*2;
  end
  pwr=pwr/2;
  
  a=big_reste(a,m);
  pm=1;
  while bit_q>0
    pm=big_reste(mul(pm,pm),m);
    if n(bit_q)>=pwr
      pm=big_reste(mul(pm,a),m);
      n(bit_q)=n(bit_q)-pwr;
    end

    pwr=floor(pwr/2);
    if pwr==0
      pwr=2^(log_base-1);
      bit_q=bit_q-1;
    end
  end
endfunction

#genere un big_num = 2^s
function p=pow2_big(s)
  global log_base
  q=floor(s/log_base);
  r=rem(s,log_base);
  p=zeros(1,q);
  p(q+1)=2^r;
endfunction

#fonction (a|n) itérative (pour le test de primalite probabiliste de Solovay Strassen)
function s=Solovay_Strassen_Big(a,n)
  s=1;
  a=big_reste(a,n);
  while (columns(a)~=1 || (a~=0 && a~=1))
    if (rem(a(1),2)==0)
      p=0;
      while (rem(a(1),2)==0)
        a=div2(a,2); p=p+1;
      end
      r=rem(n(1),8);
      if (((r==3) || (r==5)) && (rem(p,2)==1))
        s=-s;
      end
    else
      r1=rem(n(1),4);
      r2=rem(a(1),4);
      t=a; a=n; n=t;
      if ((r1==r2) && (r1==3))
      	s=-s;
      end
    end
    a=big_reste(a,n);
  end
  if (a==0)
    s=0;
  end
endfunction

#fonction generatrice de grands nombres premiers avec Solovay Strassen
function n=Prime_Number_Generator_Big_SoSt(nbb, proba)
  global log_base;
  global base;
  test_nb=floor(-log(1-proba)/log(2))+1;
  
  r=rem(nbb-1,log_base)+1;
  q=floor((nbb-1)/log_base);
  if q>0
    n=zeros(1,2);
    n(1:q)=floor(base*rand(1,q));
  end
  n(q+1)=floor(2^(r-1)*rand(1,1))+2^(r-1); #bit de poids fort a 1
  n(1)=n(1)+1-rem(n(1),2);
  
  sost=0;
  n=reduc(n);
  while sost==0
    for i=1:test_nb*2
      a=floor(rand(1,1)*(base-2))+2;
      nm1=sub(n,1);
      pm=powmod_big(a,div2(nm1,2),n);
      sr=Solovay_Strassen_Big(a,n);
      if (columns(pm)==1 && (sr==1 || sr==0) && (pm==sr)) || ((sr==-1) && (columns(nm1)==columns(pm)) && all(pm==nm1))
        sost=1;
      else
        sost=0;
	break;
      end
#      disp(".");
    end
    if sost==0
      n=add(n,2);
    end
  end
endfunction

#fonction de test de primalite probabiliste de Miller-Rabin
function mr=Miller_Rabin_Big(b,s,t,n)
  pb=powmod_big(b,t,n);
  if (columns(pb)==1 && pb==1)
    mr=1;
  else
    mu=sub(n,1);
    if (columns(mu)==columns(pb) && all(pb==mu))
      mr=1;
    else
      mr=0;
      for j=1:1:s-1
        pb=powmod_big(b,mul(pow2_big(j),t),n);
        if (columns(mu)==columns(pb) && all(pb==mu))
          mr=1;
          break;
        end
      end
    end
  end
endfunction

#fonction generatrice de grands nombres premiers avec Miller-Rabin
function n=Prime_Number_Generator_Big_MRB(nbb, proba)
  global log_base;
  global base;
  test_nb=floor(-log(1-proba)/log(4))+1;
  
  s=1;
  
  r=rem(nbb-s-1,log_base)+1;
  q=floor((nbb-s-1)/log_base);
  if q>0
    t=zeros(1,2);
    t(1:q)=floor(base*rand(1,q));
  end
  t(q+1)=floor(2^(r-1)*rand(1,1))+2^(r-1); #bit de poids fort a 1
  t(1)=t(1)+1-rem(t(1),2);
    
  mr=0;
  t=reduc(t);
  n=add(mul(pow2_big(s),t),1);
  if nbb<=log_base
    mx=(2^(nbb-1))-1;
  else
    mx=base;
  end
  while (mr==0)
    for b=1:test_nb
      mr=Miller_Rabin_Big(floor(rand(1,1)*(mx-2))+2,s,t,n);
      if (mr==0)
        break;
      end
#      disp(".");
    end
    if mr==0
      t=add(t,2);
      n=add(n,4);
    end
  end
endfunction

#fonction de géneration d'une paire de clefs RSA
function keypair=Generate_Key_Pair(bit_n, bit_e, proba)
  p=Prime_Number_Generator_Big_MRB(floor(bit_n/2), proba);
  q=Prime_Number_Generator_Big_MRB(floor(bit_n/2), proba);
  e=Prime_Number_Generator_Big_MRB(bit_e, proba);
  n=mul(p,q);
  m=mul(sub(p,1), sub(q,1));
  d=inv_mod_big(e, m);
  
  pubkey.mod=n;
  pubkey.exp=e;
  
  privkey.mod=n;
  privkey.exp=d;
  
  keypair.pub=pubkey;
  keypair.priv=privkey;
endfunction

#fonction de chiffrement
function cipher=crypt(data, key)
  t=columns(key.mod);
  sd=columns(data);
  data(1,2:sd+1)=data;
  data(1)=sd;
  j=1;
  cipher=zeros(1,2);
  for i=1:t-1:sd+1
    d=data(i:min(sd+1,i+t-2)); d(1,columns(d)+1)=1;
    v=powmod_big(d, key.exp, key.mod);
    cipher(j:j+columns(v)-1)=v;
    j=j+t;
  end
endfunction

#fonction de dechiffrement
function data=uncrypt(cipher, key)
  t=columns(key.mod);
  sc=columns(cipher);
  data=powmod_big(cipher(1:t), key.exp, key.mod);
  sd=data(1); data(1,t)=0;
  i=t;
  for j=t+1:t:sc
    v=powmod_big(cipher(j:j+t-1), key.exp, key.mod);
    data(i:i+columns(v)-1)=v;
    i=i+t-1;
  end
  data=data(2:sd+1);
endfunction

#attention : les fonctions qui suivent font l'hypothese que log_base==16
#comportement indetermine si ce n'est pas le cas (explosion thermonucleaire possible !)
#de plus les fichiers ne doivent pas depasser 64 ko
#(de toute facon vu la vitesse d'execution au dela n'est guere realiste)

#sauvegarde d'une clef
function save_key(key, filename)
  f=fopen(filename,"w");
  serialkey=columns(key.mod);
  serialkey(1,2:columns(key.mod)+1)=key.mod;
  serialkey(columns(key.mod)+2:columns(key.mod)+1+columns(key.exp))=key.exp;
  fwrite(f,serialkey,"ushort");
  fclose(f);
endfunction

#chargement d'une clef
function key=load_key(filename)
  f=fopen(filename,"r");
  [serialkey,sz] = fread(f, [1,1000], "ushort");
  key.mod=serialkey(2:serialkey(1)+1);
  key.exp=serialkey(serialkey(1)+2:columns(serialkey));
  fclose(f);
endfunction

#chiffrement d'un fichier
function crypt_file(filename_clear, filename_crypted, key)
  global base;
  f=fopen(filename_clear, "r");
  w=fopen(filename_crypted, "w");
  
  m=1;p=2;data=[0 0];cpt=0;
  while (feof(f)~=1)
    [a,s]=fread(f,[1,1]);
    if s
      data(1,p)=data(1,p)+m*a;
      m=m*256;
      if m==base
        m=1;p=p+1;data(1,p)=0;
      end
      cpt=cpt+1;
    end
  end
  
  data(1)=cpt;
  
  cipher=crypt(data, key);
  fwrite(w, cipher, "ushort");
  
  fclose(w);
  fclose(f);
endfunction

#dechiffrement d'un fichier
function uncrypt_file(filename_crypted, filename_clear, key)
  fc=fopen(filename_crypted, "r");
  fw=fopen(filename_clear, "w");
  
  [cipher,sc] = fread(fc, [1,40000], "ushort");
  unciph = uncrypt(cipher, key);
  cpt=unciph(1);
  
  m=0; p=2;
  while(cpt)
    fwrite(fw, rem(unciph(p),256));
    unciph(p)=floor(unciph(p)/256);
    if m==1
      m=0;
      p=p+1;
    else
      m=1;
    end
    cpt=cpt-1;
  end
  
  fclose(fw);
  fclose(fc);
endfunction
