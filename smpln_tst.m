function [answer] = smpln_tst(xyz1,xyz2,tol)
% SMPL_TST returns logical variable whether or not the two groups of
% points are on the exact same plane.
%
%        Notes: 1.  Requires the function plane_fit.m im the local
%                   directory.
%
%               2.  Need at least (3) total points to test a plane fit
%
%        18Nov2011 * Daniel Sturnick

%#######################################################################
%
if nargin<3
  tol = 0.05;
end
%
xyz = [xyz1; xyz2];
[d,d,d,d,d,d,d,sse] = plane_fit(xyz(:,1),xyz(:,2),xyz(:,3));
%
if sse < tol
  answer = true;
else
  answer = false;
end
%
return