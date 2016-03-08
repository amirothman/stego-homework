pos=1;
bitSeq = [1 0 0 1 1 3];
im=imread('test01.jpg');
[q, bitNum] = size(bitSeq);
[maxX, maxY, maxZ] = size(im);
z=1;
im(:,:,pos) = (im(:,:,pos).-mod(im(:,:,pos),2));

im_size = (size(im(:,:,pos)));

reshapedBitSeq = repmat(bitSeq,im_size);
reshapedBitSeq = reshapedBitSeq(1:maxX,1:maxY);
equals_one = reshapedBitSeq==1;
im(:,:,pos).+equals_one

