function [f,g] = Himmelblau(x)

f = (x(1)^2+x(2)-11)^2+(x(1)+x(2)^2-7)^2;

if nargout > 1
   g = [4*(x(1)^2+x(2)-11)*x(1) + 2*(x(1)+x(2)^2-7) ; 
       2*(x(1)^2+x(2)-11) + 4*(x(1)+x(2)^2-7)*x(2)];
        
end