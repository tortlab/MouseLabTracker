function img = draw_circle(img, radius_, xc, yc, color)
% DRAW_CIRCLE Draw a circle in a matrix using the integer midpoint circle algorithm
%
% img = draw_circle(img, radius, xc, yc, color)

if isnan(xc) || isnan(yc)
    return
end

[width height unused1] = size(img);
  
function set(x, y)
    if y >= 1 && y <= width && x >= 1 && x <= height
        img(y, x, :) = color;
    end
end

xc = int16(xc);
yc = int16(yc);

for radius = radius_:radius_+1
x = int16(0);
y = int16(radius);
d = int16(1-radius);

set(xc, yc+y);
set(xc, yc-y);
set(xc+y, yc);
set(xc-y, yc);

while x < y - 1
    x = x + 1;
    
    if d < 0
        d = d + x + x + 1;
    else 
        y = y - 1;
        a = x - y + 1;
        d = d + a + a;
    end
    
    set(x+xc, y+yc);
    set(y+xc, x+yc);
    set(y+xc, -x+yc);
    set(x+xc, -y+yc);
    set(-x+xc, -y+yc);
    set(-y+xc, -x+yc);
    set(-y+xc, x+yc);
    set(-x+xc, y+yc);
end
end

end
