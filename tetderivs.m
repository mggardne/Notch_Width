function [DNX,DNY,DNZ,Vol,nodtr]=tetderivs(x,y,z,nodtr,iplt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%PROGRAM......:  tetderivs.m
%CALL.........:  [DNX,DNY,DNZ,Vol,nodtr]=tetderivs(x,y,z,nodtr); 
%DESCRIPTION..:  Reorder connectivities so that the Volume is positive  and 
%                then get the derivative matricies. 
%	
%DATE.........:	November 2003
%AUTHOR.......:	J.P. Laible 
%RIGHTS.......:	Copyright (c) 2003 by J. P. Laible.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5
  iplt = 0;
end
%
neltr = size(nodtr,1);

v1=[x(nodtr(:,2))-x(nodtr(:,1)) y(nodtr(:,2))-y(nodtr(:,1)) z(nodtr(:,2))-z(nodtr(:,1))]';
v2=[x(nodtr(:,3))-x(nodtr(:,1)) y(nodtr(:,3))-y(nodtr(:,1)) z(nodtr(:,3))-z(nodtr(:,1))]';
v3=[x(nodtr(:,4))-x(nodtr(:,1)) y(nodtr(:,4))-y(nodtr(:,1)) z(nodtr(:,4))-z(nodtr(:,1))]';

vcross=cross(v1,v2);
proj=dot(v3,vcross); 
kn=find(proj<0);
nodtr(kn,:)=nodtr(kn,[1 3 2 4]);

%
% Form the global derivatives of the linear tetra basis functions.
%

DNX=zeros(neltr,4);
DNY=zeros(neltr,4);
DNZ=zeros(neltr,4);
Vol=zeros(neltr,1);
DNrst=[-1 1 0 0 ; -1 0 1 0 ; -1 0 0 1];
Vole=zeros(neltr,1);
for ie=1:neltr
	nv=nodtr(ie,:);
	xe=x(nv); ye=y(nv); ze=z(nv);
	J=[xe(2)-xe(1) ye(2)-ye(1) ze(2)-ze(1)
	   xe(3)-xe(1) ye(3)-ye(1) ze(3)-ze(1)
	   xe(4)-xe(1) ye(4)-ye(1) ze(4)-ze(1)];
	DJ=det(J);
	DNXYZ=J\DNrst;
	DNX(ie,:)=DNXYZ(1,:); DNY(ie,:)=DNXYZ(2,:); DNZ(ie,:)=DNXYZ(3,:);
	Vol(ie)=DJ/6;
    [vole]=elementvolf(ie,x,y,z,nodtr);
    Vole(ie)=vole;
end

if iplt
  figure;
  plot(Vol,Vole);
end