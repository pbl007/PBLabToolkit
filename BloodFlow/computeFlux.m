function flux_nanolinter = computeFlux(V0,d,varargin)
%function computes RBC flux assuming laminar flow based on the following eq:
%
%   F = pi/8 * V0 * d^2
%
% where V0 is the RBC velocity measured at the center of the vessel and d is the vessel diameter
%
% For large vessels where d>>a (the effective RBC diameter) the following empirical correction is applied:
%
%  VO[1 - 4/3 * (a/d)^2] - see Shih et al 2012 JCBFM
%
% Usage
% f = computeFlux(v,d) computes flux for velocity v and diameter d.
% f = computeFlux(v,c,a) applies correction to V0 as explained above.
%
% Note: flux is returned in nanoliters
%
% Pablo Blinder - Dec 2015


if nargin>2
    a = varargin{1};
    V0 = V0 * (1-(4/3)*(a/d)^2);
end

flux = pi/8 * V0(:) .* (d(:).^2);

flux_nanolinter = flux * 1e-6;