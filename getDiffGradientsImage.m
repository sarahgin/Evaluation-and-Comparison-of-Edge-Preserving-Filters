function [diffGradientsImage,zero,new,reduced,strengthened,eliminated,same]  = getDiffGradientsImage(rows, cols, originalGradients, smoothedGradients)

zero = 0;
eliminated = 0;
new = 0;
reduced = 0;
strengthened = 0;
same = 0;

diffGradientsImage = zeros(rows, cols);
for i=1:rows
    for j=1:cols
        orig = originalGradients(i,j);
        smooth = smoothedGradients(i,j);
        if (orig == 0 && smooth == 0) %0 stays 0 - diff is 1
            zero = zero + 1;
            diffGradientsImage(i,j) = 1;
        elseif (orig > 0 && smooth == 0) % positive to 0
            eliminated = eliminated + 1;
            diffGradientsImage(i,j) = 0;
        elseif(orig == 0 && smooth > 0) %introduced a new gradient - IGNORED
            new = new + 1;
            diffGradientsImage(i,j) = 1;
        elseif(orig > 0 && smooth > 0) % positive to positive
            so = smooth./orig;
            if (so == 1) %same
                same = same + 1;
                diffGradientsImage(i,j) = so;
            elseif so < 1 %reduced gradient
                reduced = reduced + 1;
                diffGradientsImage(i,j) = so;
            elseif so > 1 %strengthened gradient
                strengthened = strengthened + 1;
                diffGradientsImage(i,j) = 1;
            end
        end
    end
end

zero = zero/(rows*cols);
eliminated = eliminated/(rows*cols);
new = new/(rows*cols);
reduced = reduced/(rows*cols);
strengthened = strengthened/(rows*cols);
same = same/(rows*cols);

end