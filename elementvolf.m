function [vole]=elementvolf(echeck1,x,y,z,nodtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%PROGRAM......: elementvolf.m
%CALL.........:   
%DESCRIPTION..: 
%	
%DATE.........:	September 2007
%AUTHOR.......:	J.P. Laible 
%RIGHTS.......:	Copyright (c) 2007 by J. P. Laible.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nload=1;
nd=nodtr(echeck1,:);
nodest=length(x);
xe=x(nd);ye=y(nd);ze=z(nd);
xyz=[xe ye ze];
nbn=[2 4 2 3
     1 3 1 4
     1 4 1 2
     1 2 1 3];
 
 r1v=[xe(nbn(nload,2))-xe(nbn(nload,1)) ye(nbn(nload,2))-ye(nbn(nload,1)) ze(nbn(nload,2))-ze(nbn(nload,1))]';
 r2v=[xe(nbn(nload,4))-xe(nbn(nload,3)) ye(nbn(nload,4))-ye(nbn(nload,3)) ze(nbn(nload,4))-ze(nbn(nload,3))]';
 r1m=norm(r1v);
 r2m=norm(r2v);
 nvec=cross(r1v,r2v);
 mag=norm(nvec);
 sinetheta=mag/r1m/r2m;
 nuxp=nvec/(r1m*r2m*sinetheta);     %unit normal vector perpendicular to base
 abase=mag/2;
 v=[xe(nload)-xe(nbn(nload,1)) ye(nload)-ye(nbn(nload,1)) ze(nload)-ze(nbn(nload,1))]';
 h=dot(v,nuxp);
 vole=(1/3)*abase*h;
 %nuyp=cross(r1v,nuxp)/r1m;         %nuyp = unit normal perpendicular to nuxp
 %nuzp=cross(nuxp,nuyp);            %nuzp = unit normal prependicular nuxp and nuyp
 
 