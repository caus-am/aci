function W = parse_sachs_asp(filename,D)

  output=importdata(filename);
  nlines=size(output,1);
  W=zeros(D,D);
  for n=1:nlines
    line=output{n};
    if strcmp(line(1:7),'causes(')
      [A,count] = sscanf(line,'causes(%d,%d)= %e');
      assert(count == 3);
      W(A(1),A(2)) = A(3);
    elseif strcmp(line(1:8),'-causes(')
      [A,count] = sscanf(line,'-causes(%d,%d)= %e');
      assert(count == 3);
      W(A(1),A(2)) = -A(3);
    else
      error(sprintf('Cannot parse "%s"',line));
    end
  end

return
