function [new_pos new_radius] = find_subject(bw_frame, old_pos, radius, orig_radius, ...
                                             region, excluded_areas)
% TRACK_OBJECT Track a single object across frames

old_x = old_pos(1);
old_y = old_pos(2);

reg_tl = region(1, :);
reg_br = region(2, :);

square_tl = [max(reg_tl(1),old_x-radius) max(reg_tl(2),old_y-radius)];
square_br = [min(reg_br(1),old_x+radius) min(reg_br(2),old_y+radius)];

n_points = 0;
accum_pos = [0 0];

for y = square_tl(2):square_br(2)
    for x = square_tl(1):square_br(1)
        if bw_frame(y, x) && ~excluded(x, y, excluded_areas)
            n_points = n_points + 1;
            accum_pos = accum_pos + [x y];
        end
    end
end

if n_points >= Constants.MinimumNumberPoints
  new_pos = round(accum_pos ./ n_points);
  new_radius = orig_radius;  
else
  new_pos = old_pos;
  growth = round(max(1, Constants.RadiusGrowthRate * radius));
  new_radius = radius + growth;
end

end


function ex = excluded(x, y, areas)
    for i = 1:size(areas, 1)
        ul = areas(i, 1, :);
        lr = areas(i, 2, :);

        if x >= ul(1) && x <= lr(1) && y >= ul(2) && y <= lr(2)
            ex = true;
            return;
        end
    end

    ex = false;
end
