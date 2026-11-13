function vol = area2vol(csvfile,slthk)
%AREA2VOL Reads the areas from an OSIRIX ROI CSV file and given the
%         slice thickness calculates the volume.
%
%         VOL = AREA2VOL(CSVFILE,SLTHK) reads the area of a ROI on each
%         slice in cm^2 from an OSIRIX ROI CSV file, CSVFILE, and given
%         the MRI slice thickness SLTHK, in mm returns the volume, VOL,
%         in cm^3.  
%
%         NOTES:  1.  The data was collected from OSIRIX using the
%                 polygon tool.
%
%                 2.  The CSV file must contain only one ROI; although,
%                 the ROI may have more than one polygon on a slice.
%
%                 3.  M-file rd_roi7hp.m must be in the current
%                 directory or path.
%
%         09-Jan-2024 * Mack Gardner-Morse
%

% ######################################################################
%
% Check for Inputs
%
if (nargin<1)
  error(' *** ERROR in AREA2VOL:  An input file name is required!');
end
%
if (nargin<2)
  error(' *** ERROR in AREA2VOL:  A slice thickness is required!');
end
%
% Open File and Read Slices and Areas
%
roi = rd_roi7hp(csvfile,true);
%
area = roi.area';       % Areas in cm^2
%
% Calculate Volume in cm^3
%
vol = sum(area)*slthk/10;
%
return