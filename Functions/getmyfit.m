function myfit = getmyfit(expression,listCoefficients,listProblems)
myfit = fittype(expression,'independent','x','coefficients',listCoefficients,'problem',listProblems);
end