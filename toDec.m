function str = toDecimal(bitstr)
  [q, maxanz] = size(bitstr);
  str='';
  subbytsstr = [];
  start = 1;
  startok = 0;
  
  %check for initial padding -> to define starting position to read
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
  
   %check for second appearance of  initial padding -> to define position to stop reading
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

  subI = [];
  anzN = 0;
  
  endpos = start; 

  while aktpos <= endpos || aktpos <= maxanz
    nextA = 1;
    subA = [];

    while nextA <= 17 && aktpos <= maxanz
      subA = [subA, num2str(bitstr(aktpos))];
      if bitstr(aktpos)==0
        anzN++;
      else
        anzN=0;
      endif
     % if anzN==20
      %  aktpos=maxanz+1;
     % endif
      nextA++;
      aktpos++;
    endwhile
    
    subI = [subI,bin2dec(strcat(subA))];
    
    % disp(anzN);
    

    str = subI;

  endwhile

endfunction