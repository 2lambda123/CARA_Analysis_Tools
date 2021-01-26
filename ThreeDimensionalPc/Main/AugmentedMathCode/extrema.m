function [xmax,imax,xmin,imin] = extrema(x,include_endpoints,sort_output)
%
%  Find extrema from a series of points, optionally including the endpoints
%  in the search.
%
%    xmax - maxima points, optionally sorted into descending order
%    imax - indexes of the xmax
%    xmin - minima points, optionally sorted into descending order
%    imin - indexes of the xmin
%

% Initialize output

xmax = [];
imax = [];
xmin = [];
imin = [];

% Vector input?

Nt = numel(x);
if Nt ~= length(x)
    error('Entry must be a vector.')
end

% Handle NaN's
inan = find(isnan(x));
indx = 1:Nt;
if ~isempty(inan)
    indx(inan) = [];
    x(inan) = [];
    Nt = length(x);
end

% Difference between subsequent elements:

dx = diff(x);

% Horizontal line

if ~any(dx)
    return;
end

% Use the middle element for flat peaks

a = find(dx~=0);              % Indexes where x changes
lm = find(diff(a)~=1) + 1;    % Indexes where a do not changes
d = a(lm) - a(lm-1);          % Number of elements in the flat peak
a(lm) = a(lm) - floor(d/2);   % Save middle elements
a(end+1) = Nt;

% Peaks

xa  = x(a);             % Series without flat peaks
b = (diff(xa) > 0);     % 1  =>  positive slopes (minima begin)  
                        % 0  =>  negative slopes (maxima begin)
xb  = diff(b);          % -1 =>  maxima indexes (but one) 
                        % +1 =>  minima indexes (but one)
imax = find(xb == -1) + 1; % maxima indexes
imin = find(xb == +1) + 1; % minima indexes
imax = a(imax);
imin = a(imin);

nmaxi = length(imax);
nmini = length(imin); 

% Add endpoints if required

Nargin = nargin;

if Nargin < 2
    include_endpoints = true;
end

if include_endpoints

    % Maximum or minumim on a flat peak at the ends?
    
    if (nmaxi==0) && (nmini==0)
        if x(1) > x(Nt)
            xmax = x(1);
            imax = indx(1);
            xmin = x(Nt);
            imin = indx(Nt);
        elseif x(1) < x(Nt)
            xmax = x(Nt);
            imax = indx(Nt);
            xmin = x(1);
            imin = indx(1);
        end
        return;
    end

    % Maximum or minumim at the ends?
    
    if (nmaxi==0) 
        imax(1:2) = [1 Nt];
    elseif (nmini==0)
        imin(1:2) = [1 Nt];
    else
        if imax(1) < imin(1)
            imin(2:nmini+1) = imin;
            imin(1) = 1;
        else
            imax(2:nmaxi+1) = imax;
            imax(1) = 1;
        end
        if imax(end) > imin(end)
            imin(end+1) = Nt;
        else
            imax(end+1) = Nt;
        end
    end
    
end

xmax = x(imax);
xmin = x(imin);

% NaN's:
if ~isempty(inan)
    imax = indx(imax);
    imin = indx(imin);
end

% Same size as x:
imax = reshape(imax,size(xmax));
imin = reshape(imin,size(xmin));

if Nargin < 3
    sort_output = false;
end

if sort_output
    % Descending order:
    [~,inmax] = sort(-xmax);
    xmax = xmax(inmax);
    imax = imax(inmax);
    [xmin,inmin] = sort(xmin);
    imin = imin(inmin);
end

return;
end