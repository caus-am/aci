function [Wcauses,Windep] = sachs_asp(X,N,exps,labels,alpha_causes,alpha_dep,alpha_conddep,indfilename,usecauses,useindeps,usecondindeps)
  D = size(X{1},2);
  sqrD = ceil(sqrt(D + 3));
  K = length(exps);
  sqrK = ceil(sqrt(K));

  % two-sample tests for each experiment and variable (observed and predicted)
  dc = zeros(K,D);
  fid=fopen(indfilename,'w');
  fprintf(fid,'node(1..%d).\n',D);
  fprintf(fid,'%%independences and dependences\n');
  Wcauses = zeros(D,D);
  Windep = zeros(D,D);

  scale_coefficient = 100;

  if usecauses
    for j=1:D
      for e=1:K
        %[h,p] = kstest2(X{1}(:,j),X{e}(:,j));
        [h,p] = ttest2(X{1}(:,j),X{e}(:,j));
        if p == 0.0
          p = 1e-250;
        end
        dc(e,j) = log(p);
        if length(exps{e}.activity) == 1 && length(exps{e}.abundance) == 0
          w = -dc(e,j) + log(alpha_causes);
          i = exps{e}.activity(1);
          if i ~= j && w > 0 
            %if isASP && i == 2
              % U0126 has effect also on PKC, Raf, ERK, JNK: 9,1,6,11
            if i==12
                % PIP2 or PIP3 causes the variables.
                fprintf(fid,'wcauses(4,%d,%d)|',j,round(w*scale_coefficient));
                fprintf(fid,'wcauses(5,%d,%d).\n',j,round(w*scale_coefficient));
            else
              fprintf(fid,'wcauses(%d,%d,%d).%%p=%e w=%e\n',i,j,round(w*scale_coefficient),p,round(w*scale_coefficient));
              Wcauses(i,j) = round(w*scale_coefficient);
            end
          elseif i ~= j && w <= 0 
            fprintf(fid,'wnotcauses(%d,%d,%d).%%p=%e w=%e\n',i,j,round(-w*scale_coefficient),p,round(-w*scale_coefficient));
            Wcauses(i,j) = round(w*scale_coefficient);
          end
        elseif length(exps{e}.activity) == 0 && length(exps{e}.abundance) == 1
          w = -dc(e,j) + log(alpha_causes);
          i = exps{e}.abundance(1);
          if i ~= j && w > 0
            fprintf(fid,'wcauses(%d,%d,%d).%%p=%e w=%e\n',i,j,round(w*scale_coefficient),p,round(w*scale_coefficient));
            Wcauses(i,j) = round(w*scale_coefficient);
          elseif i ~= j && w <= 0
            fprintf(fid,'wnotcauses(%d,%d,%d).%%p=%e w=%e\n',i,j,round(-w*scale_coefficient),p,round(-w*scale_coefficient));
            Wcauses(i,j) = round(w*scale_coefficient);
          end
        end
      end
    end
  end

  if useindeps
    %p=hsiccorr(X{1});
    [~,p]=corr(X{1});
    for i=1:D
      for j=1:D
        if p(i,j) == 0.0
          p(i,j) = 1e-250;
        end
      end
    end
    w=log(p) - log(alpha_dep);
    for i=1:D
      for j=i+1:D
        if w(i,j) < 0
          fprintf(fid,'dep(%d,%d,0,0,%d,%d).%%p=%e w=%e\n',i,j,2^D-1-2^(i-1)-2^(j-1),round(-w(i,j)*scale_coefficient),p(i,j),round(-w(i,j)*scale_coefficient));
        else
          fprintf(fid,'indep(%d,%d,0,0,%d,%d).%%p=%e w=%e\n',i,j,2^D-1-2^(i-1)-2^(j-1),round(w(i,j)*scale_coefficient),p(i,j),round(w(i,j)*scale_coefficient));
        end
      end
    end
    wcor = w;
    Windep = scale_coefficient*w;
  end

  if usecondindeps
%    figure
    for k=1:D
      ws = zeros(9,9);
      for i=1:D
        if i~=k
          for j=i+1:D
            if j~=k
              [~,p]=partialcorr(X{1}(:,i),X{1}(:,j),X{1}(:,k));
              if p == 0.0
                p = 1e-250;
              end
              w=log(p) - log(alpha_conddep);
              ws(i,j) = w;
              if w < 0
                fprintf(fid,'dep(%d,%d,%d,0,%d,%d).%%p=%e w=%e\n',i,j,2^(k-1),2^D-1-2^(i-1)-2^(j-1)-2^(k-1),round(-w*scale_coefficient),p,round(-w*scale_coefficient));
              else
                fprintf(fid,'indep(%d,%d,%d,0,%d,%d).%%p=%e w=%e\n',i,j,2^(k-1),2^D-1-2^(i-1)-2^(j-1)-2^(k-1),round(w*scale_coefficient),p,round(w*scale_coefficient));
              end
            end
          end
        end
      end
    end
  end

  fclose(fid);

end
