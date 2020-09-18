function C = cartoonization(im, dollarIm, mode)

if (strcmp(mode, 'DOLLAR'))
    dollarIm = normImage(dollarIm);
    dollarIm = sigmf(dollarIm,[8 0.5]);
    E = dollarIm;
elseif(strcmp(mode, 'GMAG'))
    gim = convertToGrayscale(im);
    [Gmag, Gdir] = getImageGradients(gim);
    GmagIm = sigmf(Gmag,[8 0.5]);
    E = GmagIm;
end
Q = im;
C = repmat(1-E,[1 1 3]).*Q;

end