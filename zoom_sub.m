% zoom_sub
% to zoom all subplots to same xlimits

function zoom_sub(xlims,fig)
if nargin < 2
    fig=gcf;
end

ch=get(fig,'children');
for i = 1:numel(ch)
    thisch=ch(i);
    if strcmp(get(thisch,'type'),'axes')
        if ~strcmp(get(thisch,'tag'),'legend')
            if strcmp(xlims,'auto')
                
                lns=get(thisch,'children');
                x1=[];x2=x1;
                for j=1:numel(lns)
                    thisln=lns(j);
                    if strcmp(get(thisln,'type'),'line')
                        if numel(get(thisln,'xdata'))>2
                            x1=getextr(get(thisln,'xdata'),x1,-1);
                            x2=getextr(get(thisln,'xdata'),x2,1);
                        end
                    end
                end
            else
                x1=xlims(1);
                x2=xlims(2);
            end
            set(thisch,'xlim',[x1 x2]);
            
            lns=get(thisch,'children');
            y1=[];y2=y1;
            for j=1:numel(lns)
                thisln=lns(j);
                if strcmp(get(thisln,'type'),'line')
                    if numel(get(thisln,'xdata'))>2
                        xvals=get(thisln,'xdata');
                        yvals=get(thisln,'ydata');
                        yvals=yvals((xvals>=x1)==(xvals<=x2));
                        y1=getextr(yvals,y1,-1);
                        y2=getextr(yvals,y2,1);
                    end
                end
            end
            try
                set(thisch,'ylim',[y1-eps y2+eps]);
            catch
                set(thisch,'ylimmode','auto');
            end
        end
    end
end

    function out=getextr(dat,old,flag)
        if isempty(old)
            if flag < 0
                out=min(dat);
            elseif flag > 0
                out=max(dat);
            end
        else
            if flag < 0
                out=min([old dat]);
            elseif flag > 0
                out=max([old dat]);
            end
        end
    end

end