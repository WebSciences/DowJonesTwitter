function Features = PolynomialFeatureMap(X,Y)
    Features = zeros(size(X,1), 1+size(X,2)+size(Y,2)+size(X,2)*size(Y,2));
    for i=1:size(X,1);
        Features(i,1) = 1;
        Features(i,2:(size(X,2)+1)) = X(i,:);
        Features(i,(size(X,2)+2):(size(X,2)+1+size(Y,2))) = Y(i,:);
        
        c = size(X,2)+1+size(Y,2)+1;
        for j=1:size(X,2);
            for k=1:size(Y,2);
                Features(i,c) = X(i,j)*Y(i,k);
                c = c + 1;
            end;
        end;
    end;
end

