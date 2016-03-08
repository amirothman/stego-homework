function dec = binstream2dec(str)
  [q,anz] = size(str);
  binstream = [];
  for i=1:anz
    binstream = [binstream,str2num(str(i))];
  end
    bitstream = binstream;
endfunction