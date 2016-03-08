run amirDecimal
run controller
run rsa
%RGB channel
pos = 1;

disp('get image');
% cover_image = ones(1136,640,3);
cover_image = imread("test02.jpg");
% rect = [1 1 10 10];
% [cover_image, rectangle_cropped]=imcrop(cover_image,rect);

% 
% for i=1:1:10
  % disp(size(cover_image));
  % random_pixel_values = randi(255,size(cover_image));
  % disp(size(random_pixel_values))
  % a = mod(cover_image + random_pixel_values,255);

% endfor
description = constructDescript(cover_image);
watermark_string = "dfsgdsf dfskgj";
concated = strcat(watermark_string,description);
hashed_concated = md5sum(concated,true);

keypair=Generate_Key_Pair(143, 7, 0.9);

cipher=crypt(hashed_concated, keypair.pub);

disp('get bitseq');

bitstr = toBits(watermark_string);
bitstr = signature2bits(bitstr,cipher);

disp('imbed');
WMWork = embedBits(cover_image , bitstr, pos);

% file_name = strcat("test01_with_payload.png");
% imwrite(WMWork,file_name);
% disp('get image');
% imWM=imread(file_name);
disp('get bits');
bitseq = getBits(WMWork, pos);
bitstream = toBitStream(bitseq);
str = toString(bitseq);
digital_signature = bitstream(size(bitstream)(2)-(18*45)+1:end);
disp('extact watermark')
watermark_extracted = bitstream(1:(18*45));
% add zeros and ones to suit the decoding function
watermark_extracted_padded = [zeros(1,16),ones(1,16),watermark_extracted];
disp('get watermark string')
string_watermark = toString(watermark_extracted_padded);
disp(string_watermark);
disp('get digital signature')
decimal_digital_signature = toDecimal(digital_signature);
disp('decrypt digital signature with private key')
possible_hash = uncrypt(decimal_digital_signature,keypair.priv);
disp(char(possible_hash));
disp('hash watermark string with description');
second_hash = md5sum(strcat(string_watermark,description),true);
disp('authenticated if the two hash are the same');
disp(second_hash);
% disp('get ciphertext');
% str = toDecimal(bitseq);
% disp(str);
% pt = uncrypt(str,keypair.priv);

% disp("plain text");
% disp(pt);
% break;  