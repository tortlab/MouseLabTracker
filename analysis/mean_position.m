function mean_pos = mean_position(movement)
% MEAN_POSITION Calculate the mean position of each object

[n_frames, unused1, n_objects] = size(movement.positions);
mean_pos = zeros(n_objects, 2);

for i = 1:n_objects
   mean_pos(i, 1) = sum(movement.positions(:, 1, i));
   mean_pos(i, 2) = sum(movement.positions(:, 2, i));
   mean_pos(i, :) = mean_pos(i, :) ./ n_frames;
end

end
