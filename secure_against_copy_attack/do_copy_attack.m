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

g = @(d) exp(-(d./50).^2);
imWM_filtered = imsmooth(WMWork, "p&m", 2, 0.065, g);
figure;
imshow(imWM_filtered);
%d = imWM_filtered - imWM;
%figure('name', "Average - embeded");imshow(d);
%figure('name', "Averaged");imshow(imWM_filtered);
d = WMWork - imWM_filtered;

d = abs(imWM_filtered - WMWork);
figure('name', "Embeded - Cover");
imshow(d(:,:,pos));
disp('get bits');
%cat_image = zeros(1136,640,3);

different_cover_image = imread("test01.jpg");

min_x = min([size(different_cover_image)(1) size(d)(1)]);
min_y = min([size(different_cover_image)(2) size(d)(2)]);

added_cover_mark = d(1:min_x,1:min_y,:) + different_cover_image(1:min_x,1:min_y,:);

figure('name', "Approx + Cover");imshow(added_cover_mark);
bitseq = getBits(added_cover_mark, pos);
%bitseq_2 = reshapeD(d,pos);
disp('get string');
str = toString(bitseq);
disp(str);

disp('similarity measure');
min_n = min(size(bitstr)(2),size(bitseq)(2));
similarity = similarity_measure(bitstr(:,1:min_n),bitseq(:,1:min_n));
disp(similarity);
disp('maximum similarity');
max_similarity = similarity_measure(bitstr(:,1:min_n),bitstr(:,1:min_n));
disp(max_similarity);








% bitstream = toBitStream(bitseq);
% str = toString(bitseq);
% digital_signature = bitstream(size(bitstream)(2)-(18*45)+1:end);
% disp('extact watermark')
% watermark_extracted = bitstream(1:(18*45));
% % add zeros and ones to suit the decoding function
% watermark_extracted_padded = [zeros(1,16),ones(1,16),watermark_extracted];
% disp('get watermark string')
% string_watermark = toString(watermark_extracted_padded);
% disp(string_watermark);
% disp('get digital signature')
% decimal_digital_signature = toDecimal(digital_signature);
% disp('decrypt digital signature with private key')
% possible_hash = uncrypt(decimal_digital_signature,keypair.priv);
% disp(char(possible_hash));
% disp('hash watermark string with description');
% second_hash = md5sum(strcat(string_watermark,description),true);
% disp('authenticated if the two hash are the same');
% disp(second_hash);




% disp('get ciphertext');
% str = toDecimal(bitseq);
% disp(str);
% pt = uncrypt(str,keypair.priv);

% disp("plain text");
% disp(pt);
% break;  