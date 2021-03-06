function [shoulderSliceNum,noseSliceNum] = getShoulderStartSlice(outerStrMask3M,planC,outerStrName)
% Automatically identify shoulder start slice in H&N scans based on
% size of patient outline.
%
% AI 8/7/19
%
%------------------------------------------------------------------------
% INPUT
% outerStrMask3M   : Mask of pt outline. Set to [] to use structure name
%                    instead.
% outerStrName     : Structure name corresponding to pt outline
%------------------------------------------------------------------------
% AI 10/3/19 Modified to return nose slice

if isempty(outerStrMask3M)
    %Get mask of outer structure
    indexS = planC{end};
    strC = {planC{indexS.structures}.structureName};
    strIdx = getMatchingIndex(outerStrName,strC,'exact');
    outerStrMask3M = getStrMask(strIdx, planC);
end

noseSliceNum = getNoseSlice(outerStrMask3M,planC);

%Get size on each slice
infMask3M = outerStrMask3M(:,:,noseSliceNum+1:end);
[sel,colIdxM] = max(infMask3M, [], 2);
colIdxM = squeeze(sel.*(colIdxM)).';
colIdxM(colIdxM==0) = nan;
minColV = nanmin(colIdxM,[],2);

[sel,colIdxM] = max(fliplr(infMask3M), [], 2);
colIdxM = squeeze(sel.*(colIdxM)).';
colIdxM(colIdxM==0) = nan;
maxColV = size(infMask3M,2) - nanmin(colIdxM,[],2) + 1;

sizV = maxColV - minColV;

%Find sudden jump in size if any
sizV = movmean(sizV,10);
diffV = [0;diff(sizV)];
[~,argMax] = max(diffV);

if (sizV(argMax)-max(sizV(1:50))) / max(sizV(1:50)) > .2
    shoulderSliceNum = argMax + noseSliceNum - 1;
else
    % If not substantially wider, return last slice
    % (assumes shoulders not included)
    shoulderSliceNum = size(outerStrMask3M,3);
end

end