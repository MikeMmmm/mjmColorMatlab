function mjmAxisFormat(ax)

% gray axis with subtle white grid
grid on; box off
set(ax,'Color',[.9 .9 .9],'GridColor','w','GridAlpha',1)
set(ax,'TickDir','out')
set(ax,'FontSize',12)
set(get(get(ax,'XRuler'),'Axle'),'Visible','off')
set(get(get(ax,'XRuler'),'MajorTick'),'ColorData',repmat(uint8(255),4,1))
set(get(get(ax,'YRuler'),'Axle'),'Visible','off')
set(get(get(ax,'YRuler'),'MajorTick'),'ColorData',repmat(uint8(255),4,1))
