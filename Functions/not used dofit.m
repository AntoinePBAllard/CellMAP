function fitted = dofit(myfit,deflection,force,valueProblems,valueCoefficients)

    fitted = fit(deflection,force,myfit,'problem',valueProblems,'StartPoint',valueCoefficients,'Exclude',cond);
end