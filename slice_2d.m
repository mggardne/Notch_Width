function [slx,cntr,nvec,r] = slice_2d(dat,iplt);
%SLICE_2D Gets the distance between slice data from digitized MRI.
%
%         SLX = SLICE_2D(DAT) given a cell array containing three (3)
%         columns matrices with slice coordinate point data, DAT,
%         returns the distances between adjacent slices, SLX.
%
%         [SLX,CNTR,NVEC,R] = SLICE_2D(DAT) returns the means (centers)
%         of slices in the rows of matrix CNTR, the normal vector of the
%         plane fit of each slice in the columns of NVEC, and the 3x3
%         rotation matrix for each fit in a 3x3x number of slices N-D
%         array R.
%
%         NOTES:  1.  Each slice coordinate data matrix must correspond
%                 to one index into the cell array DAT.
%
%                 2.  The direction of the slice spacing is determined
%                 by fitting a plane to the slice data.  See slice_x.m
%                 and slice_z.m for different implementations.  This
%                 one is usually the most accurate.
%
%                 3.  The M-file plane_fit.m must be in the current
%                 path or directory.
%
%         14-Mar-2011 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<2)
  iplt = false;
end
%
if (nargin<1)
  error(' *** ERROR in slice_2d:  No input data!'); 
end
%
% Open Figure
%
if iplt
  hf = figure;
  orient tall;
  hold on;
  view(3);
end
%
% Get Number of Slices and Initialize Variables
%
nsl = size(dat,1);
%
cntr = zeros(nsl,3);
nvec = zeros(3,nsl);
r = zeros(3,3,nsl);
%
% Fit Plane to Slices
%
for k = 1:nsl;
   xyz = dat{k};
   [cntr(k,:),nvec(:,k),coeff,r(:,:,k)] = plane_fit(xyz(:,1),xyz(:,2), ...
                                                  xyz(:,3));
%     
   if iplt
     npt = size(xyz,1);
     plot3(xyz(:,1),xyz(:,2),xyz(:,3),'k.-','LineWidth',1);
     text(xyz(:,1),xyz(:,2),xyz(:,3),int2str((1:npt)'));
     text(xyz(1,1),xyz(1,2),xyz(1,3),int2str(k),'Color','b', ...
          'FontSize',12);
   end
%
end
%
if iplt
  axis equal;
end
%
% Get Slice Separation Distance
%
slx = zeros(nsl-1,1);
%
for k = 2:nsl;
   slx(k-1) = (cntr(k,:)-cntr(k-1,:))*nvec(:,k-1);
   if slx(k-1)<0
     slx(k-1) = -slx(k-1);
     nvec(:,k-1) = -nvec(:,k-1);
   end
%
   if (iplt)
     sc = 1;
     xp = repmat(cntr(k-1,1),2,1)+sc*[0; nvec(1,k-1)];
     yp = repmat(cntr(k-1,2),2,1)+sc*[0; nvec(2,k-1)];
     zp = repmat(cntr(k-1,3),2,1)+sc*[0; nvec(3,k-1)];
     plot3(xp,yp,zp,'r-','LineWidth',2);
   end
end
%
% Check Last Slice
%
idir = nvec(:,nsl-1)'*nvec(:,nsl);
if idir<0
  nvec(:,nsl) = -nvec(:,nsl);
end
%
return