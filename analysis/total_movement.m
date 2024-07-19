function dist = total_movement(movement)
% TOTAL_MOVEMENT Calculate the total distance covered by each object

[n_frames, unused1, n_objects] = size(movement.positions);
dist = zeros(n_objects, 1);

for i = 1:n_objects
    pos = movement.positions(1, :, i);
    
    for j = 2:n_frames
        n_pos = movement.positions(j, :, i);
        dist(i) = dist(i) + point_distance(pos, n_pos);
        pos = n_pos;
    end
end
end


function dist = point_distance(pa, pb)
% POINT_DISTANCE Euclidian distance between two points
dist = 0;

for i = 1:length(pa)
    dist = dist + (pa(i)-pb(i)) ^ 2;
end;

dist = sqrt(dist);
end
