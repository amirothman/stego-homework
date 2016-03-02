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
  for I=1:16
    bitstr = [bitstr, 0];
  endfor
  for I=1:16
    bitstr = [bitstr, 1];
  endfor
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

function im = embedBits(im, bitSeq, pos)
  [q, bitNum] = size(bitSeq);
  [maxX, maxY, maxZ] = size(im);
  z = 1;
  im(:,:,pos) = (im(:,:,pos)-mod(im(:,:,pos),2));
  im_size = (size(im(:,:,pos)));
  reshapedBitSeq = repmat(bitSeq,im_size);
  reshapedBitSeq = reshapedBitSeq(1:maxX,1:maxY);
  equals_one = reshapedBitSeq==1;
  added_one = im(:,:,pos)+equals_one;
  im(:,:,pos) = added_one;
endfunction

function bitSeq = getBits(im, pos)
  [maxX, maxY, maxZ] = size(im);
  bitSeq = mod(im(:,:,pos),2);
  ln = maxX * maxY;
  bitSeq = resize(bitSeq,1,ln);
endfunction

function bitSeq = reshapeD(im,pos)
  [maxX, maxY, maxZ] = size(im);
  ln = maxX * maxY;
  bitSeq = resize(im(:,:,pos),1,ln);
endfunction

clear;

watermark_string = "dfsgdsf dfskgj dfjsgkdfsj gnjksdfeg";

%RGB channel
pos = 1;

disp('get image');
cover_image = ones(1136,640,3);
cover_image = imread("test02.jpg");
disp('get bitseq');
bitstr = toBits(watermark_string);
disp('imbed');
WMWork = embedBits(cover_image , bitstr, pos);
file_name = strcat("test01_with_payload.png");
figure('name', "WMWork");imshow(WMWork);
imwrite(WMWork,file_name);
disp('get image');
imWM = imread(file_name);
figure('name', "Cover work");imshow(cover_image);
figure('name', "imWM");imshow(imWM);
%filter with averaging
g = @(d) exp(-(d./50).^2);
imWM_filtered = imsmooth(imWM, "p&m", 2, 0.065, g);
figure;
imshow(imWM_filtered);
%d = imWM_filtered - imWM;
%figure('name', "Average - embeded");imshow(d);
%figure('name', "Averaged");imshow(imWM_filtered);
d = imWM - imWM_filtered;

%d = abs(imWM_filtered - imWM);
figure('name', "Embeded - Cover");
imshow(d);
disp('get bits');
%cat_image = zeros(1136,640,3);
added_cover_mark = d + cover_image;
figure('name', "Approx + Cover");imshow(added_cover_mark);
bitseq = getBits(added_cover_mark, pos);
%bitseq_2 = reshapeD(d,pos);
disp('get string');
str = toString(bitseq);
disp(str);
%disp('get string appr.');
%str_2 = toString(bitseq_2);

%disp(str_2);

break; 	
