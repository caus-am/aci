addpath([pwd '/util']);
addpath([pwd '/../../code-extern/lbfgs']);

if ~exist('datafile')
  error 'Please define datafile before calling init_sachs (e.g., ../../data/sachs.csv)';
else
  fprintf(sprintf('Initing using %s\n', datafile));
end

isOctave = exist('OCTAVE_VERSION') ~= 0;
if isOctave
  A = dlmread(datafile,[],1,0);
  orglabels = {'Raf','Mek','PLCg','PIP2','PIP3','Erk','Akt','PKA','PKC','p38','JNK','experiment'};
else
  A = importdata(datafile);
  orglabels = A.colheaders;
  A = A.data;
end
% remove apostrophes
for i=1:length(orglabels)
  if orglabels{i}(1) == '"'
    orglabels{i} = orglabels{i}(2:end);
  end
  if orglabels{i}(end) == '"'
    orglabels{i} = orglabels{i}(1:end-1);
  end
end
if ~exist('expsfile')
  error 'Please define expsfile before calling init_sachs (e.g., ../../data/noICAM.exps)';
else
  fprintf(sprintf('Initing using %s\n', expsfile));
end
[D,K,vars,expVar,exps,labels] = read_exps(expsfile,orglabels,size(A,2));

X = cell(K,1);
N = cell(K,1);
if ~exist('takeLog')
  error 'Please define takeLog before calling init_sachs';
end

for e=1:K
  X{e} = A(find(A(:,expVar) == exps{e}.e), vars);
  if takeLog
    fprintf('Taking log of data for experiment %d...\n',e);
    X{e} = log(X{e});  % take log
  else
    fprintf('NOT Taking log of data for experiment %d...\n',e);
  end
  N{e} = size(X{e},1);
end

clear A e expVar i orglabels vars;
