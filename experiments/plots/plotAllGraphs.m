xcrit  = 'reca';
ycrit = 'prec';

if exist('roc')
if roc == 1
    xcrit  = 'fpr';
    ycrit = 'tpr';
end
end

mult = ones(size(true));
if exist('identifiable')
    if identifiable == 1
        mult = abs(oraclefci);
    end
    if identifiable == -1
        mult = abs(oraclefci);
        mult(mult==0) = 2;
        mult(mult==1) = 0;
        mult(mult==2) = 1;
    end
end

clear A
list_of_matrices = who;

XYs = struct();

% put NANs on all diagonals (n, the number of variables, needs to be defined!)
diagonal = zeros(size(true));
for i=1:length(diagonal)/n^2
  for j=1:n
    diagonal((i-1)*n^2+n*(j-1)+j) = nan;
  end
end

for i = 1:length(list_of_matrices)
    eval(strcat('A =', list_of_matrices{i}, ';'));
    if isempty(findstr(list_of_matrices{i}, 'true')) && isempty(findstr(list_of_matrices{i}, 'mult')) && isempty(findstr(list_of_matrices{i}, 'diagonal'))
        if all(size(true) == size(A))
            [X Y T AUC] = perfcurve(true, sign(pos - 0.5)*A.* mult + diagonal, pos, 'xCrit', xcrit, 'yCrit', ycrit);
            XY = struct('X', X, 'Y', Y);
            XYs.(list_of_matrices{i}) = XY;
        end
    end
end

colors = [
	  146/255 25/255 252/255;
	  249/255 131/255 4/255;
	  26/255 168/255 5/255;
          201/255 143/255 252/255; 
          143/255, 227/255, 252/255;
	  176/255, 252/255, 143/255;
          143/255, 227/255, 252/255;
          0, 1, 0;
          1, 0, 0;
          0, 0, 1;
          0, 1, 1;
          0, 0, 0;
          1, 0.6, 0.6;
          0.1 0.6 0.6;
          0.6 0.6 1;
          1 0.6 1;
          1 0.6 0.6;
          0.3 0.3 0.3;
	  0.3 0 0 
	  0 0.3 0
	  0 0 0.3];
                                                            
  
labels = struct();

labels.('cfci') = 'Bootstrapped (100) CFCI';
labels.('combine') = 'COMBINE';
labels.('fci') = 'Bootstrapped (100) FCI';
labels.('hej') = 'HEJ (c=1)';
labels.('hej_4') ='HEJ (c=4)';
labels.('aci') ='ACI (c=1)';
labels.('aci_4') ='ACI (c=4)';
labels.('aci_1') ='ACI (c=1, i=1)';
labels.('bnlearn') ='Score-based (bnlearn)';
labels.('cfci_1') ='Anytime CFCI (c=1)';
labels.('fci_1') ='Anytime FCI (c=1)';
labels.('vanilla_cfci') ='Standard CFCI';
labels.('vanilla_fci') ='Standard FCI';
labels.('aci_hej') ='ACI + HEJ direct (c=1)';
labels.('hej_direct') ='HEJ direct (c=1)';
          
styles_struct = struct();
styles_struct.('cfci') = ':k*';
styles_struct.('combine') = '-ys';
styles_struct.('fci') = '--g.';
styles_struct.('hej') = ':r*';
styles_struct.('aci') ='-.b.';
%styles_struct.('aci_1') ='-m.';
styles_struct.('aci_4') =':c.';
styles_struct.('hej_4') =':m.';
styles_struct.('bnlearn') =':y.';
styles_struct.('cfci_1') =':k.';
styles_struct.('fci_1') =':g.';
styles_struct.('hej_direct') = ':r.';
styles_struct.('aci_hej') =':b*';

styles_struct.('vanilla_cfci') =':mv';
styles_struct.('vanilla_fci') =':cd';


styles = {'--g*';
          '-bs';
          '-.r+';
          ':r*';
          '-.r.';
          '--cs';
          '-r>';
          '--rd';
          '--gv';
          '-bs';
          '-.ro';
          '-.rx';
          '-.rx';
          '--cs';
          '-r>';
          '--rd'};

f = figure('visible','on');
hold on

L = zeros(0,1);

fields = fieldnames(XYs);
count=1;

legend_labels = {};
for i = 1:numel(fields)
    label = fields(i);

    if isfield(labels, label{1})
        legend_labels{i} = labels.(label{1});
    else
        legend_labels{i} = label{1};
    end
    if isfield(styles_struct, label{1})
        style = styles_struct.(label{1});
    else
        style = styles{count};
        count = count + 1;
    end
    if findstr('vanilla', label{1}) & findstr('cfci', label{1})
        LA = plot(XYs.(label{1}).('X'), XYs.(label{1}).('Y'), 'kd', 'MarkerSize', 11);
        set(LA(1),'MarkerFaceColor', colors(1,:));
    else
        if findstr('vanilla', label{1}) & findstr('fci', label{1})
            LA = plot(XYs.(label{1}).('X'), XYs.(label{1}).('Y'), 'kv', 'MarkerSize', 11);
            set(LA(1), 'MarkerFaceColor', colors(2,:));
        else
            LA = plot(XYs.(label{1}).('X'), XYs.(label{1}).('Y'), style);
            if ~isfield(styles_struct, label{1})
                set(LA(1),'color', colors(count + 2,:));
            	count = count + 1;
	    end
        end
    end
end


if exist('roc')
    xlabel('Recall'); ylabel('Precision')
    if pos ==1
        location = 'northeast';
    else
        location = 'southwest';
    end
else
    location = 'southeast';
    xlabel('FPR'); ylabel('TPR')
end

leg = legend(legend_labels, 'Location', location)
set(leg,'FontSize',16,'FontName','Times New Roman');

xlabel('Recall','FontName','Times New Roman','FontSize',16);
ylabel('Precision','FontName','Times New Roman','FontSize',16);

xlim(xlimit);
ylim(ylimit);

hold off
