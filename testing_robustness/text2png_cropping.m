%pkg install "image-2.4.1.tar.gz";
%pkg load all;
%pkg install "control-2.8.5.tar.gz";
%pkg install "signal-1.3.2.tar.gz";
pkg load all;

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

clear;

watermark_string = "H2sdf";

%RGB channel
pos = 1;

disp('get image');
cover_image =imread('test01.jpg');
disp('get bitseq');
bitstr = toBits(watermark_string);
disp('imbed');
WMWork = embedBits(cover_image , bitstr, pos);

file_name = strcat("test01_with_payload.png");
imwrite(WMWork,file_name);

disp('get image');
imWM=imread(file_name);
[dimX,dimY,dimZ] = size(imWM);

crop_to_percentage = 0.01;
initial_x = round((1 - crop_to_percentage)*dimX);
initial_y = round((1 - crop_to_percentage)*dimY);

width = round(crop_to_percentage*dimX);
height = round(crop_to_percentage*dimY);
disp(size(imWM));


%rect = [1 1 639 1135];
rect = [1 1 64 1]
[imWM_cropped, rectangle_cropped]=imcrop(imWM,rect);
imshow(imWM);
figure;
imshow(imWM_cropped);
imwrite(imWM_cropped,"test_with_payload_cropped.png");
disp(size(imWM_cropped));
disp('get bits');
bitseq = getBits(imWM_cropped, pos);

disp('get string');
str = toString(bitseq);
disp(str);

break;