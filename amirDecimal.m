% run rsa.m

% function bitstream = binstring2stream(str)
%   [q,anz] = size(str);
%   binstream = [];
%   for i=1:anz
%     binstream = [binstream,str2num(str(i))];
%   end
%     bitstream = binstream;
% endfunction

% mesej = [12 23 34 45];
% disp('plain text');
% disp(mesej);

% kp = Generate_Key_Pair(143,17,0.5);

% ct = crypt(mesej,kp.pub);
% disp("ciphertext");
% disp(ct);

% % encode

% binary_form = [];

% binary_form = [binary_form, zeros(1,16)];

% binary_form = [binary_form, ones(1,16)];

% bit_length_for_number = 17;

% for i=1:size(ct)(2)
%   val = ct(i);
%   str = dec2bin(val,bit_length_for_number);
%   bitstream = binstring2stream(str);
%   binary_form = [binary_form, bitstream];
% endfor

% binary_form = [binary_form, zeros(1,20)];

% for i=1:4
%   binary_form = [binary_form, binary_form];
% endfor

%disp('binary_form');
%disp(binary_form);

%decode this mufuka

function found = match_signature(signature,list)
  found = 1;
  for i=1:size(signature)(2)
    if signature(i) != list(i)
      found = 0;
      break;
    end
  endfor
endfunction

function decimals = toDecimal(binary_form)
  bit_length_for_number = 18;
  beginning_signature = [zeros(1,16),ones(1,16)];
  ending_signature = [zeros(1,20)]

  offset = 32;

  for i=1:size(binary_form)(2)
    if match_signature(beginning_signature,binary_form(i:end))
      disp('match_signature');
      disp(i);
      % offset += i+32-1;
      break
    endif
  endfor

  extracted = [];

  for i=1:size(binary_form)(2)
    extracted = [extracted,binary_form(i+offset)];
    if match_signature(beginning_signature,binary_form((1+i+offset):end))
      break
    endif
  endfor

  % disp(extracted);
  new_ct = []
  for i=1:bit_length_for_number:size(extracted)(2)+1-bit_length_for_number
    str_array = extracted(i:i+(bit_length_for_number-1));

    str ='';

    for j=1:size(str_array)(2)
      str = strcat(str,num2str(str_array(j)));
    endfor
    disp(str);
    disp(bin2dec(str));
    new_ct = [new_ct,bin2dec(str)];
  endfor

  decimals = new_ct;

endfunction
% ct = new_ct;
% pt = uncrypt(ct,kp.priv);

% disp("plain text");
% disp(pt);