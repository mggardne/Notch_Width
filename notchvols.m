%#######################################################################
%
%                      * NOTCH VOLumeS Program *
%
%          M-File which reads ten (10) notch volume segmentation CSV
%     files to estimate the notch volumes using different selections of
%     slices.  The initial (and presumably best) volume estimate uses
%     all of the slices.  Subsequent estimates use every second slice,
%     every third slice, etc. up to every seventh slice.  The estimated
%     volumes are output to the MS-Excal spreadsheet, notchvols.xlsx.
%
%     NOTES:  1.  M-files elementvolf.m, encl_area.m, plane_fit.m,
%             plt_datslv.m, rd_roi7hp.m, sl_dir.m, tetderivs.m and
%             tri_area.m must be in the current directory or path.
%
%     25-Sep-2024 * Mack Gardner-Morse
%

%#######################################################################
%
% Plot Control
%
iplt = true;            % Plot segmentations
% iplt = false;           % No segmentation plots
% iplts = true;           % Plot slice areas
iplts = false;          % No slice area plots
% ipltv = true;           % Plot volumes
ipltv = false;          % No volume plots
%
% Input Notch Volume Segmentation CSV File Names
%
fnams = [ '004_L_AX_NOTCHVOL_AC.csv'
          '006_R_AX_NOTCHVOL_AC.csv'
          '008_L_AX_NOTCHVOL_AC.csv'
          '010_L_AX_NOTCHVOL_AC.csv'
          '013_R_AX_NOTCHVOL_AC.csv'
          '016_R_AX_NOTCHVOL_AC.csv'
          '020_L_AX_NOTCHVOL_AC.csv'
          '021_L_AX_NOTCHVOL_AC.csv'
          '022_R_AX_NOTCHVOL_AC.csv'
          '023_L_AX_NOTCHVOL_AC.csv' ];
%
nsubj = size(fnams,1);  % Number of subjects
%
subjs = fnams(:,1:3);   % ID number of subjects
legs = fnams(:,5);      % Letter of leg side ('L' - left or 'R' - right)
psfiles = [fnams(:,1:6) repmat('nvols.ps',nsubj,1)];
%
% Read Segmentation Data into Data Structure "sdat"
%
for k = nsubj:-1:1
%
   fnam = fnams(k,:);
%
   dat3 = rd_roi7hp(fnam);             % 3D coordinate data
%
   dat = rd_roi7hp(fnam,true);         % 2D coordinate data
   dat.data = dat.data';
   dat.area = dat.area';               % Area
   dat.data3 = dat3.data';
   dat.nslices = size(dat.data,1);     % Number of slices
   dat.id = subjs(k,:);                % Subject ID number
   dat.fnam = fnam;                    % CSV file name
%
   sdat(k) = dat;       % Put into a data structure for all ten (10) subjects
%
% Plot Segmentations
%
   if iplt
     figure;
     orient tall;
     plt_datslv(sdat(k).data3,'k.-');
     xlabel('X (mm)','FontSize',12,'FontWeight','bold');
     ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
     zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
     title(fnam,'FontSize',16,'FontWeight','bold','Interpreter', ...
           'none');
     print('-dpsc2','-r600','-fillpage',psfiles(k,:));
   end
%
end
%
if iplt
  pause;
  close all;
end
%
% Loop through the Subjects
%
mxsldiff = 7;           % Maximum difference between slices
volo = zeros(nsubj,mxsldiff);          % Volume based on OsiriX areas
volsl = zeros(nsubj,mxsldiff);         % Volume based on triangulation areas
voltet = zeros(nsubj,mxsldiff);        % Volume based on tetrahedrons
%
if ipltv
  hv = figure;
  orient tall;
  %
  hv2 = figure;
  orient tall;
end
%
for k = 1:nsubj
%
% Get 3D Data, Number of Slices, and OsiriX Areas
%
   dat3 = sdat(k).data3;
   nsl = sdat(k).nslices;
   oarea = sdat(k).area;
%
% Get Slice Areas
%
   slarea = zeros(nsl,1);
%
   if iplts
     hf = gobjects(nsl,1);
   end
%
   for l = 1:nsl
      if iplts
        slarea(l) = encl_area(dat3{l},true)/100; % in cm^2
        title(['Slice ' int2str(l)],'FontSize',16,'FontWeight','bold');
        hf(l) = gcf;
      else
        slarea(l) = encl_area(dat3{l})/100;      % in cm^2
      end
   end
%
% Loop through Different Number of Slices
%
   for l = 1:mxsldiff   % Take every l slice
%
% Get Index to Slices
%
      idx = 1:l:nsl;
      if idx(end)~=nsl
        idx = [idx nsl];
      end
%
% Get Slice Separation Distances
%
      [~,slx] = sl_dir(dat3(idx),true);
      slx = [slx(1)/2; slx(2:end-1); (slx(end-1)+slx(end))/2; ...
             slx(end)/2];
      slx = slx/10;     % in cm
%
% Get Volumes based on the Areas and Slice Separations
%
      volo(k,l) = sum(oarea(idx).*slx);
      volsl(k,l) = sum(slarea(idx).*slx);
%
% Get Volumes based on 3D Delaunay Triangulation and Tetrahedrons
%
      ni = size(idx,2);
      nr = ni-1;
      vols = zeros(nr,1);
%
      for m = 1:nr
         tet = delaunayTriangulation(cell2mat(dat3([idx(m) idx(m+1)])));
         xyz = tet.Points;
         tets = tet.ConnectivityList;
         [~,~,~,v] = tetderivs(xyz(:,1),xyz(:,2),xyz(:,3),tets);
         vols(m) = sum(v);
         if ipltv
           figure(hv);
           plt_datslv(dat3(idx(m)),'k.-');
           hold on;
           ht = ele_shr(tets,xyz,1);
           set(ht,'FaceColor','none','EdgeColor',[0.6 0.6 0.6], ...
               'EdgeAlpha',0.8);
           if m==nr
             plt_datslv(dat3(idx(m+1)),'k.-');
           end
%
           figure(hv2);
           ht2 = tetramesh(tets,xyz);
           set(ht2,'EdgeColor','k','FaceColor','none');
           hold on;
%
         end
%
      end
%
      if ipltv
        figure(hv2);
        plt_datslv(dat3(idx),'r.-');
        title(['Loop ' int2str(l)],'FontSize',16,'FontWeight','bold');
        pause;
        clf(hv);
        clf(hv2);
      end
%
      voltet(k,l) = sum(vols)/1000;    % in cm^3
%
   end
%
   if iplts
     pause;
     close(hf);
     clear hf;
   end
%
end
%
% Write Volumes to MS-Excal Spreadsheet
%
xlsnam = 'notchvols.xlsx';             % Results spreadsheet
hdrv = ['Subject' 'Leg' cellstr([repmat('Slice Every ',mxsldiff,1) ...
        int2str((1:mxsldiff)')])'];
%       
t1 = table(subjs,legs,'VariableNames',hdrv(1:2));
t2 = array2table(volo,'VariableNames',hdrv(3:end));
t = [t1 t2];
%
writetable(t,xlsnam,'WriteMode','replacefile');
%
return