%pkg install "image-2.4.1.tar.gz";
%pkg load all;
%pkg install "control-2.8.5.tar.gz";
%pkg install "signal-1.3.2.tar.gz";
pkg load all;
close all;
function bitstr = toBits(str)
  bytestr = toascii(str);
  [q, anz] = size(bytestr);
  bitstr = [];
  bitstr = [bitstr, zeros(1,16)];
  bitstr = [bitstr, ones(1,16)];

  for I=1:anz
    val = bytestr(I);
    for J=1:8
      if val >= 2^(8-J)
        val = val-2^(8-J);
        bitstr = [bitstr, 1];
      else
        bitstr = [bitstr, 0];
      endif
    endfor
  endfor
  for I=1:8
    bitstr = [bitstr, 0];
  endfor
endfunction

function bitstream = binstring2stream(str)
  [q,anz] = size(str);
  binstream = [];
  for i=1:anz
    binstream = [binstream,str2num(str(i))];
  end
    bitstream = binstream;
endfunction

function dec = binstream2dec(str)
  [q,anz] = size(str);
  binstream = [];
  for i=1:anz
    binstream = [binstream,str2num(str(i))];
  end
    bitstream = binstream;
endfunction

function bitstr = signature2bits(watermark,str)
  bytestr = str;
  [q, anz] = size(bytestr);
  
  
  for I=1:anz
    val = bytestr(I);
    binstring = dec2bin(val,18);
    watermark = [watermark,binstring2stream(binstring)];
  endfor
  bitstr = watermark;
endfunction

function str = toString(bitstr)
  [q, maxanz] = size(bitstr);
  str='';
  subbytsstr = [];
  start = 1;
  startok = 0;
  while startok<32 && start < maxanz
    while startok<16 && start < maxanz
      if bitstr(start)==0
        startok++;
      else
        startok=0;
      endif
      start++;
    endwhile
    while startok>=16 && startok<32 && start < maxanz
      if bitstr(start)==1
        startok++;
      else
        startok=0;
      endif
      start++;
    endwhile
  endwhile
  aktpos = start;
  while aktpos <= maxanz
    nextA = 0;
    anzN = 0;
    subA = [];
    while nextA<8 && aktpos <= maxanz
      subA = [subA, bitstr(aktpos)];
      if bitstr(aktpos)==0
        anzN++;
      else
        anzN=0;
      endif
      nextA++;
      aktpos++;
    endwhile
    if anzN==8 
      aktpos=maxanz+1;
    elseif nextA != 8 
      aktpos=maxanz+1;
    else
      byte = 0;
      for I=1:8
        byte=2*byte + subA(I);
      endfor
      subbytsstr = [subbytsstr, byte];
    endif
  endwhile
  [q, anzchar] = size(subbytsstr);
  if anzchar>0
    str = char(subbytsstr);
  endif
endfunction

% function str = toDecimal(bitstr)
%   [q, maxanz] = size(bitstr);
%   str='';
%   subbytsstr = [];
%   start = 1;
%   startok = 0;
%   while startok<32 && start < maxanz
%     while startok<16 && start < maxanz
%       if bitstr(start)==0
%         startok++;
%       else
%         startok=0;
%       endif
%       start++;
%     endwhile
%     while startok>=16 && startok<32 && start < maxanz
%       if bitstr(start)==1
%         startok++;
%       else
%         startok=0;
%       endif
%       start++;
%     endwhile
%   endwhile
%   aktpos = start;

%   subI = [];
%   anzN = 0;

%   while aktpos <= maxanz
%     nextA = 1;
%     subA = [];

%     while nextA <= 17 && aktpos <= maxanz
%       subA = [subA, num2str(bitstr(aktpos))];
%       if bitstr(aktpos)==0
%         anzN++;
%       else
%         anzN=0;
%       endif
%       if anzN==20
%         aktpos=maxanz+1;
%       endif
%       nextA++;
%       aktpos++;
%     endwhile
    
%     subI = [subI,bin2dec(strcat(subA))];
    
%     % disp(anzN);
    

%     str = subI;

%   endwhile

% endfunction

% function im = embedBits(im, bitSeq, pos)
%   [q, bitNum] = size(bitSeq);
%   [maxX, maxY, maxZ] = size(im);
%   z = 1;
%   im(:,:,pos) = (im(:,:,pos)-mod(im(:,:,pos),2));
%   im_size = (size(im(:,:,pos)));
%   reshapedBitSeq = repmat(bitSeq,im_size);
%   reshapedBitSeq = reshapedBitSeq(1:maxX,1:maxY);
%   % equals_one = reshapedBitSeq==1;
%   added_one = im(:,:,pos)+reshapedBitSeq;
%   im(:,:,pos) = added_one;
% endfunction

function im = embedBits(im, bitSeq, pos)
  disp('slow embedBits');
  [q, bitNum] = size(bitSeq);
  [maxX, maxY, maxZ] = size(im);
  z=1;
  
  % For one channel from RGB
  % Subtract one to odd pixels (elementwise).
  im(:,:,pos) = (im(:,:,pos).-mod(im(:,:,pos),2));

  for x=1:maxX
    for y=1:maxY
      if bitSeq(z) == 1
         im(x,y,pos) = im(x,y,pos)+1;
      endif
      z++;
      if z>bitNum
        z=1;
      endif
    endfor
  endfor
endfunction

% function bitSeq = getBits(im, pos)
%   [maxX, maxY, maxZ] = size(im);
%   bitSeq = mod(im(:,:,pos),2);
%   ln = maxX * maxY;
%   bitSeq = resize(bitSeq,1,ln);
% endfunction

function bitSeq = getBits(im, pos)
  disp('slow getBits')
  bitSeq = [];
  [maxX, maxY, maxZ] = size(im);
  for x=1:maxX
    for y=1:maxY
      bitSeq = [bitSeq, mod(im(x,y,pos),2)];
    endfor
  endfor
endfunction

function bitSeq = reshapeD(im,pos)
  [maxX, maxY, maxZ] = size(im);
  ln = maxX * maxY;
  bitSeq = resize(im(:,:,pos),1,ln);
endfunction

clear;

function description = constructDescript(im)
  [x,y,z] = size(im)
  description = int2str(x*y*z) 
endfunction
