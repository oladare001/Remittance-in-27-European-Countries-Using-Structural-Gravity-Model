

*import excel "\\domenis.ut.ee\DFS\Desktops\darestep\Desktop\Stephupdate\MastermergepartA.xlsx", sheet("Sheet1") firstrow clear


import excel "\\domenis.ut.ee\DFS\Desktops\darestep\Desktop\Stephupdate\MastermergepartAB4COVID.xlsx", sheet("Sheet1") firstrow clear





rename Sending_countries exporter
rename Receiving_countries importer

*STATA commands to create importer- and exporter-time fixed effects:
egen exp_time = group(exporter Year)
tabulate exp_time, generate(EXPORTER_TIME_FE)
egen imp_time = group(importer Year)
tabulate imp_time, generate(IMPORTER_TIME_FE)




*STATA commands to compute country-pair fixed effects: 
* Asymmetric country-pair fixed effects
egen pair_id = group(exporter importer)
          tabulate pair_id, generate(PAIR_FE)
		  
		  
		  
		  
		  
		  
* Log generation
generate log_Bilateral_Remitance = log(Bilateral_Remitance)
generate log_dist = log(dist)
generate log_comlang_off = log(comlang_off)
generate log_gdp_o = log(gdp_o)
generate log_gdp_d = log(gdp_d)
generate log_gdpcap_o = log(gdpcap_o)
generate log_gdpcap_d = log(gdpcap_d)

generate log_Sim_fin_inst = log(Sim_fin_inst)


generate log_gdpadjusted_o = log(gdpadjusted_o)
generate log_gdpadjusted_d = log(gdpadjusted_d)
		  
* Symmetric country-pair fixed effects
* Short-cut code valid if none of the pairs has identical distances. 
*egen pair_id = group(DIST)
          *tabulate pair_id, generate(PAIR_FE)
		  


*gravity estimation code issue here(Large file issue)
*glm Bilateral_Remitance Sim_fin_inst  EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE* , cluster(pair_id) family(poisson) diff iter(30)



/*
unable to allocate matrix;
    You have attempted to create a matrix with too many rows or columns or attempted to fit a model with too many variables.

    You are using Stata/IC which supports matrices with up to 800 rows or columns.  See limits for how many more rows and columns Stata/SE and
    Stata/MP can support.

    If you are using factor variables and included an interaction that has lots of missing cells, try set emptycells drop to reduce the
    required matrix size; see help set emptycells.

    If you are using factor variables, you might have accidentally treated a continuous variable as a categorical, resulting in lots of
    categories.  Use the c. operator on such variables.
r(915);

*/


*gravity estimation (excluded PAIR_FE*)
glm Bilateral_Remitance Sim_fin_inst  EXPORTER_TIME_FE* IMPORTER_TIME_FE* , cluster(pair_id) family(poisson) diff iter(30)

* STATA commands to estimate standard gravity model with the OLS estimator and
* without intra-national trade flows:
generate ln_Bilateral_Remitance = ln(Bilateral_Remitance)
generate ln_Sim_fin_inst = ln(Sim_fin_inst)


regress ln_Bilateral_Remitance  ln_Sim_fin_inst, cluster(pair_id)

/*

Linear regression                               Number of obs     =      6,538
                                                F(1, 643)         =       9.01
                                                Prob > F          =     0.0028
                                                R-squared         =     0.0107
                                                Root MSE          =     2.6567

                                 (Std. Err. adjusted for 644 clusters in pair_id)
---------------------------------------------------------------------------------
                |               Robust
ln_Bilateral_~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
----------------+----------------------------------------------------------------
ln_Sim_fin_inst |  -.5846979   .1948197    -3.00   0.003    -.9672575   -.2021382
          _cons |   4.361433   .8972104     4.86   0.000     2.599616    6.123249
---------------------------------------------------------------------------------



*/




regress ln_Bilateral_Remitance Sim_fin_inst, cluster(pair_id)

regress Bilateral_Remitance Sim_fin_inst  EXPORTER_TIME_FE* IMPORTER_TIME_FE*, cluster(pair_id)

/*


*/

regress Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst PairedEuroZone, cluster(pair_id)

regress Sim_fin_inst i.Eurozone_o##i.Eurozone_d 


regress Bilateral_Remitance c.Sim_fin_inst##i.Eurozone_o##i.Eurozone_d 




*  PART1: PPML fin inst without pair fixed effects and country-time fixed effects

ppml Bilateral_Remitance log_Sim_fin_inst log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig , cluster(pair_id)

/*


Number of parameters: 6
Number of observations: 7330
Pseudo log-likelihood: -377264.76
R-squared: .47578339
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
 log_Sim_fin_inst |  -.0229703   .1393352    -0.16   0.869    -.2960623    .2501218
        log_gdp_o |   .7599739   .0777142     9.78   0.000     .6076569    .9122908
log_gdpadjusted_d |   .4900471   .0702864     6.97   0.000     .3522884    .6278059
 distw_arithmetic |  -.0004949   .0001751    -2.83   0.005     -.000838   -.0001518
           contig |   1.084509   .2325646     4.66   0.000     .6286905    1.540327
            _cons |  -15.70439   1.973005    -7.96   0.000    -19.57141   -11.83737
-----------------------------------------------------------------------------------





SECOND PART2(2017)





*/

*PPML  Euroarea

ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst Eurozone_o Eurozone_d, cluster(pair_id)

/*


Number of parameters: 8
Number of observations: 7330
Pseudo log-likelihood: -365116.07
R-squared: .48960607
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7180812   .0839492     8.55   0.000     .5535437    .8826187
log_gdpadjusted_d |   .4390762   .0661866     6.63   0.000     .3093529    .5687995
 distw_arithmetic |  -.0005936   .0001764    -3.37   0.001    -.0009394   -.0002479
           contig |   1.027552   .2305121     4.46   0.000     .5757562    1.479347
 log_Sim_fin_inst |   .1080673   .1529042     0.71   0.480    -.1916195    .4077541
       Eurozone_o |   .3038936   .2161976     1.41   0.160    -.1198459    .7276331
       Eurozone_d |    .454658   .2016057     2.26   0.024     .0595181    .8497979
            _cons |  -8.675299    1.38202    -6.28   0.000    -11.38401   -5.966589
-----------------------------------------------------------------------------------


. 
SECOND PART2(2017)







*/


* PPML with pair Euroarea
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst PairedEuroZone, cluster(pair_id)

/*



Number of parameters: 7
Number of observations: 7330
Pseudo log-likelihood: -366238.55
R-squared: .48611075
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7146506   .0756028     9.45   0.000     .5664718    .8628294
log_gdpadjusted_d |   .4529838   .0667266     6.79   0.000     .3222019    .5837656
 distw_arithmetic |   -.000572   .0001733    -3.30   0.001    -.0009116   -.0002324
           contig |   1.048285   .2294019     4.57   0.000     .5986655    1.497904
 log_Sim_fin_inst |   .1335857     .15848     0.84   0.399    -.1770295    .4442008
   PairedEuroZone |   .4419521   .2045162     2.16   0.031     .0411077    .8427965
            _cons |  -8.613799   1.345159    -6.40   0.000    -11.25026   -5.977335
-----------------------------------------------------------------------------------



SECOND PART2(2017)





*/


*PPML  Fixedrate
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst Fixedrate_o Fixedrate_d, cluster(pair_id)

/*



Number of parameters: 8
Number of observations: 7330
Pseudo log-likelihood: -368936.43
R-squared: .48884408
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7347039   .0786938     9.34   0.000     .5804669    .8889408
log_gdpadjusted_d |   .4733305    .070147     6.75   0.000     .3358448    .6108161
 distw_arithmetic |  -.0005165   .0001752    -2.95   0.003    -.0008598   -.0001731
           contig |   1.066721   .2307327     4.62   0.000      .614493    1.518948
 log_Sim_fin_inst |   .0439593   .1363244     0.32   0.747    -.2232316    .3111502
      Fixedrate_o |  -.9882431   .2475433    -3.99   0.000    -1.473419   -.5030671
      Fixedrate_d |  -.5801213   .3417111    -1.70   0.090    -1.249863    .0896202
            _cons |  -8.439544   1.392462    -6.06   0.000    -11.16872    -5.71037
-----------------------------------------------------------------------------------



SECOND PART2(2017)






*/

*PPML with paired Fixedrate
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst PairedFixedrate, cluster(pair_id)

/*


Number of parameters: 7
Number of observations: 7330
Pseudo log-likelihood: -377255.64
R-squared: .47582779
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7596216   .0779513     9.74   0.000     .6068399    .9124033
log_gdpadjusted_d |   .4897731   .0704694     6.95   0.000     .3516556    .6278907
 distw_arithmetic |  -.0004949    .000175    -2.83   0.005    -.0008379   -.0001519
           contig |    1.08473   .2326117     4.66   0.000     .6288191     1.54064
 log_Sim_fin_inst |  -.0227472    .139414    -0.16   0.870    -.2959937    .2504993
  PairedFixedrate |   -.187013   .4463608    -0.42   0.675    -1.061864    .6878382
            _cons |  -8.698497   1.410309    -6.17   0.000    -11.46265   -5.934342
-----------------------------------------------------------------------------------



SECOND PART2





*/



*PPML  Floatrate
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst Floatingrate_d Floatingrate_o, cluster(pair_id)

/*



Number of parameters: 8
Number of observations: 7330
Pseudo log-likelihood: -368936.43
R-squared: .48884408
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7347039   .0786938     9.34   0.000     .5804669    .8889408
log_gdpadjusted_d |   .4733305    .070147     6.75   0.000     .3358448    .6108161
 distw_arithmetic |  -.0005165   .0001752    -2.95   0.003    -.0008598   -.0001731
           contig |   1.066721   .2307327     4.62   0.000      .614493    1.518948
 log_Sim_fin_inst |   .0439593   .1363244     0.32   0.747    -.2232316    .3111502
   Floatingrate_d |   .5801213   .3417111     1.70   0.090    -.0896202    1.249863
   Floatingrate_o |   .9882431   .2475433     3.99   0.000     .5030671    1.473419
            _cons |  -10.00791   1.430935    -6.99   0.000    -12.81249   -7.203327
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------

------



SECOND PART2







*/



*PPML  with paired Floatrate
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst PairedFloatingrate, cluster(pair_id)

/*



Number of parameters: 7
Number of observations: 7330
Pseudo log-likelihood: -369223.25
R-squared: .48903027
Option strict is: off
                                    (Std. Err. adjusted for 702 clusters in pair_id)
------------------------------------------------------------------------------------
                   |               Robust
Bilateral_Remita~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------------+----------------------------------------------------------------
 log_gdpadjusted_o |   .7406243   .0772919     9.58   0.000      .589135    .8921135
 log_gdpadjusted_d |   .4697272   .0689015     6.82   0.000     .3346828    .6047716
  distw_arithmetic |  -.0005156   .0001753    -2.94   0.003    -.0008591    -.000172
            contig |   1.067019   .2305804     4.63   0.000     .6150892    1.518948
  log_Sim_fin_inst |   .0445623   .1364896     0.33   0.744    -.2229523    .3120769
PairedFloatingrate |   .7406097   .2413579     3.07   0.002      .267557    1.213663
             _cons |  -9.211675   1.401212    -6.57   0.000      -11.958   -6.465351
------------------------------------------------------------------------------------







SECOND PART2(2017)





*/


*PPML fin Sim for EU 
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst eu_o eu_d, cluster(pair_id)


/*

Number of parameters: 8
Number of observations: 7330
Pseudo log-likelihood: -367278.94
R-squared: .5035007
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7823152   .0806701     9.70   0.000     .6242047    .9404256
log_gdpadjusted_d |   .4684372   .0674259     6.95   0.000      .336285    .6005895
 distw_arithmetic |  -.0005067    .000172    -2.95   0.003    -.0008439   -.0001696
           contig |   1.088587   .2283595     4.77   0.000     .6410109    1.536164
 log_Sim_fin_inst |    .007044   .1420822     0.05   0.960     -.271432    .2855199
             eu_o |  -.2408354   .1927028    -1.25   0.211    -.6185259    .1368551
             eu_d |   .5797815   .2566885     2.26   0.024     .0766813    1.082882
            _cons |  -9.155729    1.50009    -6.10   0.000    -12.09585   -6.215606
-----------------------------------------------------------------------------------




SECOND PART2(2017)





*/



*EU membership
generate EU_pairs=.
replace EU_pairs=1 if (eu_o==1 & eu_d==1)
replace EU_pairs=0 if missing(EU_pairs)



*PPML fin Sim for EU Pairs
ppml Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d distw_arithmetic contig log_Sim_fin_inst EU_pairs, cluster(pair_id)




/*


Number of parameters: 7
Number of observations: 7330
Pseudo log-likelihood: -376374.27
R-squared: .47903763
Option strict is: off
                                   (Std. Err. adjusted for 702 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   .7538081   .0766613     9.83   0.000     .6035547    .9040614
log_gdpadjusted_d |   .4862827   .0696131     6.99   0.000     .3498435    .6227219
 distw_arithmetic |  -.0005072   .0001729    -2.93   0.003    -.0008461   -.0001683
           contig |   1.087983   .2315323     4.70   0.000     .6341877    1.541778
 log_Sim_fin_inst |   .0043045    .144397     0.03   0.976    -.2787084    .2873174
         EU_pairs |   .1401757   .2086077     0.67   0.502    -.2686878    .5490393
            _cons |  -8.812934   1.412623    -6.24   0.000    -11.58162   -6.044245
-----------------------------------------------------------------------------------



SECOND PART2(2017)






*/






/*




*/











* PART 2 : PPML fin inst with pair fixed effects and without country-time fixed effects
   
   *PPML GDP
ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst, absorb(PAIR_FE*) cluster(pair_id) 


/*


HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(3)    =      11.07
Deviance             =  29977.62746               Prob > chi2     =     0.0113
Log pseudolikelihood = -27409.37946               Pseudo R2       =     0.9771

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0590899   .1766544    -0.33   0.738    -.4053262    .2871464
log_gdpadjusted_d |    .299563    .156985     1.91   0.056     -.008122     .607248
 log_Sim_fin_inst |   .0490534    .037805     1.30   0.194    -.0250431    .1231499
            _cons |   3.487968   1.190525     2.93   0.003     1.154581    5.821354
-----------------------------------------------------------------------------------


SECOND PART2(2017)









*/

*Here  
  *PPML EU membership
ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst EU_pairs, absorb(PAIR_FE*) cluster(pair_id) 

/*


HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(4)    =      20.37
Deviance             =  29952.48109               Prob > chi2     =     0.0004
Log pseudolikelihood = -27396.80628               Pseudo R2       =     0.9771

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0544028    .176937    -0.31   0.758     -.401193    .2923873
log_gdpadjusted_d |   .2946991   .1575413     1.87   0.061    -.0140762    .6034745
 log_Sim_fin_inst |   .0478646   .0377395     1.27   0.205    -.0261035    .1218326
         EU_pairs |  -.1151441   .0499487    -2.31   0.021    -.2130418   -.0172465
            _cons |   3.586661   1.190892     3.01   0.003     1.252555    5.920766
-----------------------------------------------------------------------------------



SECOND PART2(2017)







*/


ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst eu_o eu_d, absorb(PAIR_FE*) cluster(pair_id) 

/*


HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(5)    =      18.74
Deviance             =  29943.57625               Prob > chi2     =     0.0021
Log pseudolikelihood = -27392.35386               Pseudo R2       =     0.9771

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |   -.052184   .1772938    -0.29   0.769    -.3996735    .2953056
log_gdpadjusted_d |   .2925523   .1580343     1.85   0.064    -.0171893    .6022938
 log_Sim_fin_inst |   .0480126    .037753     1.27   0.203    -.0259818    .1220071
             eu_o |   .2643408    .253557     1.04   0.297    -.2326218    .7613035
             eu_d |   -.111254   .0580854    -1.92   0.055    -.2250993    .0025913
            _cons |   3.361422    1.21371     2.77   0.006     .9825945    5.740249
-----------------------------------------------------------------------------------




SECOND PART2(2017)






*/




  *PPML Fixed rate
ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst Fixedrate_o Fixedrate_d, absorb(PAIR_FE*) cluster(pair_id)


/*



HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(5)    =      28.33
Deviance             =  29918.46783               Prob > chi2     =     0.0000
Log pseudolikelihood = -27379.79965               Pseudo R2       =     0.9772

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0618934   .1766489    -0.35   0.726    -.4081189    .2843321
log_gdpadjusted_d |   .3107129   .1570529     1.98   0.048     .0028948     .618531
 log_Sim_fin_inst |   .0491069   .0376055     1.31   0.192    -.0245985    .1228122
      Fixedrate_o |  -.3227357   .0938924    -3.44   0.001    -.5067614     -.13871
      Fixedrate_d |   .1115876   .1245856     0.90   0.370    -.1325957    .3557708
            _cons |   3.395524   1.195807     2.84   0.005     1.051785    5.739264
-----------------------------------------------------------------------------------






SECOND PART2(2017)







*/


ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst PairedFixedrate, absorb(PAIR_FE*) cluster(pair_id)

/*



HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(4)    =      14.77
Deviance             =   29968.7587               Prob > chi2     =     0.0052
Log pseudolikelihood = -27404.94508               Pseudo R2       =     0.9771

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0599936    .176671    -0.34   0.734    -.4062624    .2862752
log_gdpadjusted_d |   .2971893   .1571384     1.89   0.059    -.0107963    .6051749
 log_Sim_fin_inst |   .0491094   .0378017     1.30   0.194    -.0249807    .1231994
  PairedFixedrate |   -.177127   .1149789    -1.54   0.123    -.4024814    .0482275
            _cons |   3.525232   1.193453     2.95   0.003     1.186107    5.864356
-----------------------------------------------------------------------------------









SECOND PART2(2017)








*/

  *PPML Floating rate
ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst Floatingrate_o Floatingrate_d, absorb(PAIR_FE*) cluster(pair_id)


/*


HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(5)    =      28.33
Deviance             =  29918.46783               Prob > chi2     =     0.0000
Log pseudolikelihood = -27379.79965               Pseudo R2       =     0.9772

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0618934   .1766489    -0.35   0.726    -.4081189    .2843321
log_gdpadjusted_d |   .3107129   .1570529     1.98   0.048     .0028948     .618531
 log_Sim_fin_inst |   .0491069   .0376055     1.31   0.192    -.0245985    .1228122
   Floatingrate_o |   .3227357   .0938924     3.44   0.001       .13871    .5067614
   Floatingrate_d |  -.1115876   .1245856    -0.90   0.370    -.3557708    .1325957
            _cons |   3.184376   1.176265     2.71   0.007     .8789384    5.489814
-----------------------------------------------------------------------------------











SECOND PART2(2017)









*/

ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst PairedFloatingrate, absorb(PAIR_FE*) cluster(pair_id)

/*

HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(4)    =      12.08
Deviance             =  29963.39675               Prob > chi2     =     0.0168
Log pseudolikelihood = -27402.26411               Pseudo R2       =     0.9771

Number of clusters (pair_id)=        644
                                    (Std. Err. adjusted for 644 clusters in pair_id)
------------------------------------------------------------------------------------
                   |               Robust
Bilateral_Remita~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------------+----------------------------------------------------------------
 log_gdpadjusted_o |  -.0572207   .1765427    -0.32   0.746    -.4032381    .2887967
 log_gdpadjusted_d |   .3080224   .1568602     1.96   0.050      .000582    .6154627
  log_Sim_fin_inst |   .0492674   .0376772     1.31   0.191    -.0245786    .1231133
PairedFloatingrate |  -.0723339    .125356    -0.58   0.564    -.3180271    .1733593
             _cons |   3.438942      1.186     2.90   0.004     1.114424     5.76346
------------------------------------------------------------------------------------





SECOND PART2(2017)







*/

ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst Eurozone_o Eurozone_d, absorb(PAIR_FE*) cluster(pair_id)



/*



HDFE PPML regression                              No. of obs      =      6,856
Absorbing 702 HDFE groups                         Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(5)    =      28.33
Deviance             =  29918.46783               Prob > chi2     =     0.0000
Log pseudolikelihood = -27379.79965               Pseudo R2       =     0.9772

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |  -.0618934   .1766489    -0.35   0.726    -.4081189    .2843321
log_gdpadjusted_d |   .3107129   .1570529     1.98   0.048     .0028948     .618531
 log_Sim_fin_inst |   .0491069   .0376055     1.31   0.192    -.0245985    .1228122
       Eurozone_o |   .3227357   .0938924     3.44   0.001       .13871    .5067614
       Eurozone_d |  -.1115876   .1245856    -0.90   0.370    -.3557708    .1325957
            _cons |    3.21883   1.179037     2.73   0.006       .90796      5.5297
-----------------------------------------------------------------------------------







SECOND PART2(2017)






*/






*PART(3)
*PPML fin inst with pair fixed effects and with country-time fixed effects


ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst distw_arithmetic contig, absorb(EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE*) cluster(pair_id) 

/*

HDFE PPML regression                              No. of obs      =      6,777
Absorbing 1296 HDFE groups                        Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(1)    =       0.02
Deviance             =  10542.26107               Prob > chi2     =     0.8962
Log pseudolikelihood = -17691.69627               Pseudo R2       =     0.9851

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |          0  (omitted)
log_gdpadjusted_d |          0  (omitted)
 log_Sim_fin_inst |  -.0028825   .0220899    -0.13   0.896    -.0461778    .0404128
 distw_arithmetic |          0  (omitted)
           contig |          0  (omitted)
            _cons |   6.420811   .0963951    66.61   0.000      6.23188    6.609742
-----------------------------------------------------------------------------------



SECOND PART2(2017)





S


*/



ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst contig  Fixedrate_o Fixedrate_d, absorb(EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE*) cluster(pair_id) 




/*



HDFE PPML regression                              No. of obs      =      6,777
Absorbing 1296 HDFE groups                        Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(1)    =       0.02
Deviance             =  10542.26107               Prob > chi2     =     0.8962
Log pseudolikelihood = -17691.69627               Pseudo R2       =     0.9851

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |          0  (omitted)
log_gdpadjusted_d |          0  (omitted)
 log_Sim_fin_inst |  -.0028825   .0220899    -0.13   0.896    -.0461778    .0404128
           contig |          0  (omitted)
      Fixedrate_o |          0  (omitted)
      Fixedrate_d |          0  (omitted)
            _cons |   6.420811   .0963951    66.61   0.000      6.23188    6.609742
-----------------------------------------------------------------------------------






SECONDPART2(2017)






*/





ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst contig  Eurozone_o Eurozone_d, absorb(EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE*) cluster(pair_id) 


/*



HDFE PPML regression                              No. of obs      =      6,777
Absorbing 1296 HDFE groups                        Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(1)    =       0.02
Deviance             =  10542.26107               Prob > chi2     =     0.8962
Log pseudolikelihood = -17691.69627               Pseudo R2       =     0.9851

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |          0  (omitted)
log_gdpadjusted_d |          0  (omitted)
 log_Sim_fin_inst |  -.0028825   .0220899    -0.13   0.896    -.0461778    .0404128
           contig |          0  (omitted)
             eu_o |          0  (omitted)
             eu_d |          0  (omitted)
            _cons |   6.420811   .0963951    66.61   0.000      6.23188    6.609742
-----------------------------------------------------------------------------------




SECONDPART2(2017)





*/

ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst contig  eu_o eu_d, absorb(EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE*) cluster(pair_id)

/*




HDFE PPML regression                              No. of obs      =      6,777
Absorbing 1296 HDFE groups                        Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(1)    =       0.02
Deviance             =  10542.26107               Prob > chi2     =     0.8962
Log pseudolikelihood = -17691.69627               Pseudo R2       =     0.9851

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |          0  (omitted)
log_gdpadjusted_d |          0  (omitted)
 log_Sim_fin_inst |  -.0028825   .0220899    -0.13   0.896    -.0461778    .0404128
           contig |          0  (omitted)
             eu_o |          0  (omitted)
             eu_d |          0  (omitted)
            _cons |   6.420811   .0963951    66.61   0.000      6.23188    6.609742
-----------------------------------------------------------------------------------




			
			
SECONDPART2(2017)			
			
			
			

*/





ppmlhdfe Bilateral_Remitance log_gdpadjusted_o log_gdpadjusted_d log_Sim_fin_inst contig  Floatingrate_o Floatingrate_d, absorb(EXPORTER_TIME_FE* IMPORTER_TIME_FE* PAIR_FE*) cluster(pair_id)


/*
HDFE PPML regression                              No. of obs      =      6,777
Absorbing 1296 HDFE groups                        Residual df     =        643
Statistics robust to heteroskedasticity           Wald chi2(1)    =       0.02
Deviance             =  10542.26107               Prob > chi2     =     0.8962
Log pseudolikelihood = -17691.69627               Pseudo R2       =     0.9851

Number of clusters (pair_id)=        644
                                   (Std. Err. adjusted for 644 clusters in pair_id)
-----------------------------------------------------------------------------------
                  |               Robust
Bilateral_Remit~e |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
log_gdpadjusted_o |          0  (omitted)
log_gdpadjusted_d |          0  (omitted)
 log_Sim_fin_inst |  -.0028825   .0220899    -0.13   0.896    -.0461778    .0404128
           contig |          0  (omitted)
   Floatingrate_o |          0  (omitted)
   Floatingrate_d |          0  (omitted)
            _cons |   6.420811   .0963951    66.61   0.000      6.23188    6.609742
-----------------------------------------------------------------------------------

*/



