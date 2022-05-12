* Final Project SAS Code - Red Wine Dataset

* Importing file and printing dataset;
TITLE "IMPORT";
PROC IMPORT datafile="winequality-red.csv" out = wine replace;
delimiter = ',';
getnames = yes;
run;

TITLE "Wine Dataset";
PROC PRINT;
RUN;

*Drop quality variable;
data wine_new;
* set copies original dataset;
set wine;
drop quality;
RUN;
proc print data = wine_new;
RUN;

* Generate Scatterplots;
TITLE "Scatterplots";
PROC sgscatter;
matrix density fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol;
RUN;

* Generate Correlation Matrix;
TITLE "Correlations";
PROC corr;
VAR density fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol;
RUN;

* Run Descriptives for Density;
TITLE "Descriptives";
PROC MEANS mean std stderr clm min p25 p50 p75 max range qrange;
VAR density;
RUN;

* Generate Histogram for Density;
TITLE "Histogram for Density";
PROC UNIVARIATE normal;
VAR density;
histogram / normal (mu=est sigma=est);
RUN;

* Generate Full Model Regression Analysis - with VIF statistics;
TITLE "Regression Analysis - Full Model";
PROC REG;
MODEL density = fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol/vif stb;
* Residual plot: residuals vs pred. values;
plot student.*predicted.;
* Residual plot: residuals vs x-vars;
plot student.*(fixed_acidity volatile_acidity citric_acid residual_sugar chlorides free_sulfur_dioxide total_sulfur_dioxide pH sulphates alcohol);
* Normal probability plot;
plot npp.*student.;
RUN; QUIT;
RUN;


* Apply transformations to the variables if needed (make sure to use wine_new from now on);

data wine_new;
set wine_new;
sqrtSulphates=sqrt(sulphates);
sqrtVolatile=sqrt(volatile_acidity);
sqrtRsugar=sqrt(residual_sugar);
sqrtFreesulfur=sqrt(free_sulfur_dioxide);
sqrtTotalsulfur=sqrt(total_sulfur_dioxide);
sqrtChl=sqrt(chlorides);
run;
proc print data=wine_new;
run;

proc reg;
model density = sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity citric_acid pH alcohol;
run;
* Split data into training/testing;



*Select Train and Test Observations;
* Compute regression analysis with the training set using at least 2 different variable selection methods;

title "Test and Train Sets For Density";
proc surveyselect data=wine_new out=xv_all seed=56749
samprate=0.75 outall;
run;

proc print;
run;

*Same dataset with train/test split to create new y var;
data xv_all;
set xv_all;
if selected then new_y=density; *If selected is equal to 1, then new_y will equal density;
run;
proc print data=xv_all;
run;

*Using training model to determine models;
title "Model Selection: stepwise & cp";
proc reg data=xv_all;
*Model 1;
model new_y=sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity citric_acid pH alcohol/ selection=stepwise; 

*Model 2;
model new_y=sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity citric_acid pH alcohol/selection=cp;
run;

* Final model analysis with options r, influence, vif, stb (also compute predicted y for the test set);
proc reg;
model new_y = sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol/influence r vif stb;
plot student.*(sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol pred.);
plot npp.*student.;
run;
* Remove influential observations and outliers/write into new dataset;
data final_wine;
set xv_all;
if _n_ in (244,245,410,494,499,500,511,557,559,609,652,653,1427) then delete;
run;

* Rerun model selection without influential points and/or outliers;
* Final model analysis with options r, influence, vif, stb;
proc reg;
model new_y = sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol/influence r vif stb;
plot student.*(sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol pred.);
plot npp.*student.;
run;

*Test the performance of the model and ;
proc reg;
model new_y = sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol;
output out=outm2(where=(new_y=.)) p=yhat;
run;

proc print;
run;

*summarize the results of the cross-val;
title "Difference between obs and pre in test set";
data outm2_wine;
set outm2;
d=density-yhat;
absd=abs(d);
run;

*compute pred. stat;

proc summary data=outm2_wine;
var d absd;
output out=outm2_stats std(d)=rmse mean(absd)=mae;
run;

proc print data=outm2_stats;
title 'Validation statistics for Model';
run;

proc corr data=outm2;
var density yhat;
run;

proc glmselect data=final_wine
	plots=(asePlot Criteria);
model density = sqrtSulphates sqrtVolatile sqrtRsugar sqrtFreesulfur sqrtTotalsulfur sqrtChl fixed_acidity pH alcohol/
	selection=backward(stop=cv)cvMethod=split(5) cvDetails=all;
run;
