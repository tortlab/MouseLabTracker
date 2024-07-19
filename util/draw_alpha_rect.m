function img = draw_alpha_rect(img, upper_left, lower_right, color)
%DRAW_ALPHA_RECT

ul_x = upper_left(1);
ul_y = upper_left(2);
lr_x = lower_right(1);
lr_y = lower_right(2);

img(ul_y:lr_y, ul_x:lr_x, 1) = min(img(ul_y:lr_y, ul_x:lr_x, 1) + color(1), 255);
img(ul_y:lr_y, ul_x:lr_x, 2) = min(img(ul_y:lr_y, ul_x:lr_x, 2) + color(2), 255);
img(ul_y:lr_y, ul_x:lr_x, 3) = min(img(ul_y:lr_y, ul_x:lr_x, 3) + color(3), 255);
end
