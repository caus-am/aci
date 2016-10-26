function [D,K,vars,expVar,exps,labels] = read_exps (filename, orglabels, cols)
  fid = fopen(filename,'r');

  % get number of variables
  line = fgetl(fid);
  D = sscanf(line,'%d');

  % get variables
  line = fgetl(fid);
  vars = tokenize(line);
  invVars = zeros(cols,1);
  for i=1:length(vars)
    v = vars(i);
    invVars(v) = i;
  end
  labels = orglabels(vars);

  % get experiment variable
  line = fgetl(fid);
  expVar = sscanf(line,'%d');

  % skip line
  line = fgetl(fid);

  % get number of experiments
  line = fgetl(fid);
  K = sscanf(line,'%d');
  exps = cell(K,1);

  for c = 1:K
    % skip line
    line = fgetl(fid);

    % get experimental condition
    line = fgetl(fid);
    exps{c}.e = sscanf(line,'%d');

    % get label
    line = fgetl(fid);
    exps{c}.label = line;

    % get abundance|activity variables
    line = fgetl(fid);
    seppos = strfind(line,'|');
    abstr = line(1:seppos-1);
    acstr = line(seppos+1:end);

    % get abundance variables
    exps{c}.abundance = invVars(tokenize(abstr));

    % get activity variables
    exps{c}.activity = invVars(tokenize(acstr));
  end

  fclose(fid);

return

function [toks] = tokenize(s)
  toks = [];
  % split string of integers, seperated by comma's
  pos = strfind(s,',');
  start = [1,pos+1];
  stop = [pos - 1,length(s)];
  for i=1:length(start)
    c = sscanf(s(start(i):stop(i)),'%d');
    toks = [toks, c];
  end
return
