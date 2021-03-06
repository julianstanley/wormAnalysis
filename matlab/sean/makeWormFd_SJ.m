function wormFd = makeWormFd_SJ(intensityData, varargin)
%SmoothIntensity Return a functional data object containing a smoothing of the
%intensity Data
%   intensityData should be length-normalized (see square).
    LAMBDA_DEFAULT = 10^.0891;
    N_ORDER_DEFAULT = 6;
    N_BREAKS_DEFAULT = 96;
    
    persistent p;
    if isempty(p)
        p = inputParser;
        p.FunctionName = 'makeWormFd_SJ';
        addParameter(p, 'lambda', LAMBDA_DEFAULT);
        addParameter(p, 'n_order', N_ORDER_DEFAULT);
        addParameter(p, 'n_breaks', N_BREAKS_DEFAULT);
    end
    
    parse(p,varargin{:});
    lambda = p.Results.lambda;
    n_order = p.Results.n_order;
    n_breaks = p.Results.n_breaks;
        
    breaks = linspace(1, 100, n_breaks);
    n_basis = length(breaks) + n_order - 2;
    
    basis_range = [1 max(breaks)];
    bspline_basis = create_bspline_basis(basis_range, n_basis, n_order, breaks);

    Lfd2 = int2Lfd(2);
    wormFdPar = fdPar(bspline_basis, Lfd2, lambda);
    argvals = linspace(basis_range(1), basis_range(2), size(intensityData, 1));
    [wormFd,~,~] = smooth_basis(argvals, intensityData, wormFdPar);
end