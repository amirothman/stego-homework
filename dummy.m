run rsa.m

function bitstream = binstring2stream(str)
  [q,anz] = size(str);
  binstream = [];
  for i=1:anz
    binstream = [binstream,str2num(str(i))];
  end
    bitstream = binstream;
endfunction

mesej = [12 23 34 45];
disp('plain text');
disp(mesej);

kp = Generate_Key_Pair(143,17,0.5);

ct = crypt(mesej,kp.pub);
disp("ciphertext");
disp(ct);

% encode

binary_form = [];

for i=1:16
  binary_form = [binary_form, 0];
endfor

for i=1:16
  binary_form = [binary_form, 1];
endfor

for i=1:size(ct)(2)
  val = ct(i);
  str = dec2bin(val,20);
  bitstream = binstring2stream(str);
  binary_form = [binary_form, bitstream];
endfor

for i=1:16
  binary_form = [binary_form, 0];
endfor

for i=1:4
  binary_form = [binary_form, binary_form]
endfor

%disp('binary_form');
%disp(binary_form);

%decode this mufuka



pt = uncrypt(ct,kp.priv);

disp("plain text");
disp(pt);