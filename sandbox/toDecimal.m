function decimals = toDecimal(bitstream)
  bit_length_for_number = 18;
  decimals = [];
  for i=1:18:size(bitstream)(2)
    str = '';
    for j=0:17
      str = strcat(str,num2str(bitstream(i+j)));
    endfor
    decimals = [decimals, bin2dec(str)];
  endfor
endfunction
