function plot_one_sachs(W,cmap,tit,D,labels, range)
  figure;
  imagesc(W);
  colormap(cmap);
  caxis([-range,range]);
  title(tit);
  set(gca,'YTick',[1:D]);
  set(gca,'YTickLabel',labels);
  % Make rotated XTickLabels
  set(gca,'XTick',[1:D]);
  set(gca,'XTickLabel','');
  ax = axis;     % Current axis limits
  axis(axis);    % Set the axis limit modes (e.g. XLimMode) to manual
  Yl = ax(3:4);  % Y-axis limits
  Xt = [1:D] + 0.5;
  t = text(Xt,Yl(2)*ones(1,length(Xt)),labels);
  set(t,'HorizontalAlignment','left','VerticalAlignment','top','Rotation',-90);
    fig = gcf;
  set(fig, 'Position', [0 0 228 152]);
  fig.PaperPositionMode = 'auto'
  fig_pos = fig.PaperPosition;
  fig.PaperSize = [fig_pos(3) fig_pos(4)+0.2];
return