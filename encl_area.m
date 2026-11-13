function [area,xyzcg,xyzp,tri] = encl_area(xyz,iplt)
%ENCL_AREA Uses a triangular mesh to calculate the area and center of
%          gravity of an open set of ordered points forming an enclosed
%          area.
%
%          AREA = ENCL_AREA(XYZ) finds the area enclosed by an open set
%          of order points in a two or three column coordinate matrix,
%          XYZ. The function duplicates the first point at the end of
%          the coordinate matrix to close the area.
%
%          [AREA,XYZCG] = ENCL_AREA(XYZ) returns the coordinates of the
%          center of gravity in XYZCG.
%
%          ENCL_AREA(XYZ,IPLT) if IPLT is true, the function plots the
%          points (black line with points), gray triangular mesh and
%          center of gravity (blue square).
%
%          NOTES:  1.  The points need to define an outline that is not
%                  too convex to create overlapping triangles.
%
%                  2.  The mean of the points should be close to the
%                  center of gravity.
%
%                  3.  Do not include the first point at the end of the
%                  input coordinate matrix.  The function automatically
%                  closes the outline.
%
%                  4.  The Matlab files tri_area.m and tri_shr.m must
%                  be in the current directory or path.
%
%          21-Apr-2020 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<1)
  error(' *** ERROR in ENCL_AREA:  Input coordinates are required!');
end
%
if (nargin<2)||isempty(iplt)
  iplt = false;
end
%
% Add Third Dimension and Close the Outline
%
[npts,ndim] = size(xyz);
%
if ndim==2
  xyz = [xyz zeros(npts,1)];
end
%
xyzm = mean(xyz);
xyzp = [xyz; xyzm];
%
% Get and Plot Area and Centroid
%
tri = [repmat(npts+1,npts-1,1) (1:npts-1)' (2:npts)'];
tri = [tri; [npts+1 npts 1]];
%
[at,cgt] = tri_area(xyzp(:,1),xyzp(:,2),xyzp(:,3),tri);
%
area = sum(at);
xyzcg = sum(repmat(at,1,3).*cgt)./area;
%
if iplt
%
  figure;
%
  idx = [1:npts 1];
  plot3(xyz(idx,1),xyz(idx,2),xyz(idx,3),'k.-','MarkerSize',7, ...
        'LineWidth',1);
  hold on;
%
%   hp = tri_shr(tri,xyzp,0.85);
  hp = tri_shr(tri,xyzp,1);
  set(hp,'EdgeColor',[0.7 0.7 0.7],'EdgeAlpha',0.5,'FaceColor','none');
%
  plot3(xyzcg(1),xyzcg(2),xyzcg(3),'bs','LineWidth',2,'MarkerSize',7);
%
  if ndim==2
    view(2);
  end
%
end
%
return