function drawPostElements(nodes, displacement, elements, stress)
% DRAWPOSTELEMENTS Draws elements in the current axes object

 global displayMode;

 i = elements.i;
 eType = elements.data(:,2);
%--------- Vertices and Faces -------------------------------------
 if isstruct(displacement)
	 verts = nodes.data(:, 2:end) + displacement.scale * displacement.data(:, 2:4);
	 cString = 'interp';
	 cAlpha = 1.0;
 else
	 % only original, no displacement and stresses
	 i = 0;
	 verts = nodes.data(:, 2:end);
	 cString = 'k';
	 cAlpha = 0.2;
 end
 
 nIDs = nodes.data(:, 1);
 enIDs = elements.data(:, 5:end);
 faces = ID2Index(enIDs, nIDs);

 % calculate x/y/zData from faces and vertices
 xData = NaN(size(faces'));
 yData = NaN(size(faces'));
 zData = NaN(size(faces'));
 
 for j = 1 : size(faces, 1)
	cface = faces(j,faces(j,:) ~= 0); % remove zero entries
	nv = size(cface, 2);
	xData(1:nv,j) = verts(cface, 1);
	yData(1:nv,j) = verts(cface, 2);
	zData(1:nv,j) = verts(cface, 3);
 end 
 
%--------- colour data ---------------------------------------------------
 if isstruct(displacement)
	 
	 colors = zeros(size(faces)); 
	 
	 switch displayMode.cSource

		 case {'stress.data'}
			 eIDs = elements.data(:,1);

			 esIndex = ID2Index(stress.data(:,1), eIDs);

			 for j = 1 : size(stress.data, 1)
				colors(esIndex(j),stress.data(j,3)) = stress.data(j,displayMode.cColumn);
			 end

			  cData = colors';

		 case {'stress.mises'}
			 eIDs = elements.data(:,1);
			 esIndex = ID2Index(stress.data(:,1), eIDs);

			 for j = 1 : size(stress.mises, 1)
				colors(esIndex(j),stress.data(j,3)) = stress.mises(j,displayMode.cColumn);
			 end

			 cData = colors';

		 case {'displacement.data'}
			 colors = displacement.data(:,displayMode.cColumn);

			 cData = NaN(size(faces'));
			 for j = 1 : size(faces, 1)
				cface = faces(j,faces(j,:) ~= 0); % remove zero entries
				nv = size(cface, 2);
				cData(1:nv,j) = colors(cface, 1);
			 end

		 case {'displacement.total'}
			 colors = displacement.total(:,displayMode.cColumn);

			 cData = NaN(size(faces'));
			 for j = 1 : size(faces, 1)
				cface = faces(j,faces(j,:) ~= 0); % remove zero entries
				nv = size(cface, 2);
				cData(1:nv,j) = colors(cface, 1);
			 end		 
	 end
	 
 else
	 
	 cData = zeros(size(xData));
	 
 end

%--------- Draw Patch ---------------------------------------------
 
 for j = 1 : size(xData,2)
	 
	 % extract numeric characters from eType(j)
	 seType = num2str(eType(j));
	 veType = [str2double(seType(1)) str2double(seType(2)) str2double(seType(3))];
	 
	 switch veType(1)
		 
		 case {1 2}	% line elements
			 if j == i	% selected element
				patch(xData(:,j), yData(:,j), zData(:,j), cData(:,j),...
					  'FaceColor', 'g', 'FaceAlpha', cAlpha,...
					  'EdgeColor', cString, 'EdgeAlpha', cAlpha, 'LineWidth', 2);
			 else	% non-selected element
				patch(xData(:,j), yData(:,j), zData(:,j), cData(:,j),...
					  'FaceColor', 'w', 'FaceAlpha', cAlpha,...
					  'EdgeColor', cString, 'EdgeAlpha', cAlpha, 'LineWidth', 2);
			 end
			 
		 case {3 4 5}	% plane elements
			 
			 if veType(2) == 8
				 % rearrange nodes so they turn counterclockwise around the
				 % center of the element
				 xx = xData([1 5 2 6 3 7 4 8],j);
				 yy = yData([1 5 2 6 3 7 4 8],j);
				 zz = zData([1 5 2 6 3 7 4 8],j);
				 cc = cData([1 5 2 6 3 7 4 8],j);
			 else
				 % no need to rearrange nodes
				 xx = xData(:,j);
				 yy = yData(:,j);
				 zz = zData(:,j);
				 cc = cData(:,j);
			 end
			 
			 if j == i	% selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'g', 'EdgeAlpha', cAlpha);
			 else	% non-selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'w', 'EdgeAlpha', cAlpha);
			 end
			 
		 case {6}	% 8 node hexahedral
	 
			 xx = [xData([1 2 3 4],j), xData([1 5 6 2],j), xData([2 6 7 3],j),...
				   xData([3 7 8 4],j), xData([4 8 5 1],j), xData([5 8 7 6],j)];

			 yy = [yData([1 2 3 4],j), yData([1 5 6 2],j), yData([2 6 7 3],j),...
				   yData([3 7 8 4],j), yData([4 8 5 1],j), yData([5 8 7 6],j)];
			 
			 zz = [zData([1 2 3 4],j), zData([1 5 6 2],j), zData([2 6 7 3],j),...
				   zData([3 7 8 4],j), zData([4 8 5 1],j), zData([5 8 7 6],j)];
			   
			 cc = [cData([1 2 3 4],j), cData([1 5 6 2],j), cData([2 6 7 3],j),...
				   cData([3 7 8 4],j), cData([4 8 5 1],j), cData([5 8 7 6],j)];
			   
			 if j == i	% selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'g', 'EdgeAlpha', cAlpha);
			 else	% non-selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'w', 'EdgeAlpha', cAlpha);
			 end
			 
		 otherwise	% unknown element, try drawing anyways
			 % try plane element since it's the most robust

			 if veType(2) == 8
				 % rearrange nodes so they turn counterclockwise around the
				 % center of the element
				 xx = xData([1 5 2 6 3 7 4 8],j);
				 yy = yData([1 5 2 6 3 7 4 8],j);
				 zz = zData([1 5 2 6 3 7 4 8],j);
				 cc = cData([1 5 2 6 3 7 4 8],j);
			 else
				 % no need to rearrange nodes
				 xx = xData(:,j);
				 yy = yData(:,j);
				 zz = zData(:,j);
				 cc = cData(:,j);
			 end
			 
			 if j == i	% selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'g', 'EdgeAlpha', cAlpha);
			 else	% non-selected element
				patch(xx, yy, zz, cc,...
					  'FaceColor', cString, 'FaceAlpha', cAlpha,...
					  'EdgeColor', 'w', 'EdgeAlpha', cAlpha);
			 end
			 
	 end
 end
 
end

