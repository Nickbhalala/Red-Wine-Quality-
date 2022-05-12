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
* Split data into training/testing;
* Compute regression analysis with the training set using at least 2 different variable selection methods;
* Final model analysis with options r, influence, vif, stb (also compute predicted y for the test set);
* Remove influential observations and outliers/write into new dataset;
* Rerun model selection without influential points and/or outliers;
* Final model analysis with options r, influence, vif, stb;
