function result = estimate_movement(result)

orig_radius = result.radius;
positions = result.positions;
radius_progress = result.radius_progress;

n_frames = size(positions, 1);

function lost = is_lost(i, object)
    lost = (radius_progress(i, 1, object) ~= orig_radius);
end

for object = 1:result.number_subjects
  i = 2;
  
  while i <= n_frames
      if ~is_lost(i, object)
          i = i + 1;
          continue;
      end
      
      j = i + 1;
      while j <= n_frames
          if ~is_lost(j, object)
              break;
          end
          j = j + 1;
      end
      
      if j <= n_frames
          start_i = i-1;
          end_i = j;
          frames_lost = start_i+1:end_i-1;
          
          p1 = positions(start_i, :, object);
          p2 = positions(end_i, :, object);
          
          px = polyfit([start_i end_i], [p1(1) p2(1)], 1);
          py = polyfit([start_i end_i], [p1(2) p2(2)], 1);
          
          result.positions(frames_lost, 1, object) = round(polyval(px, frames_lost));
          result.positions(frames_lost, 2, object) = round(polyval(py, frames_lost));
    
          i = j + 1;
      else
          i = i + 1;
      end
  end
end
    


end

