Getting and Cleaning Data Course Project
========================================================

This is an R Markdown document. 
 
I will use the "sqldf" library to perform some data manipulation:

```r
library("sqldf")
```

```
## Loading required package: gsubfn
## Loading required package: proto
## Loading required package: RSQLite
## Loading required package: DBI
## Loading required package: RSQLite.extfuns
```


Set my working directory:

```r
setwd("~/Documents/CURSOS/Getting and Cleaning Data/UCI HAR Dataset")
```


Read the activity and column labels data sets: 

```r
activity_labels <- read.table("activity_labels.txt", col.names = c("activity_ID", 
    "activity_name"))
column_labels <- read.table("features.txt", col.names = c("column_ID", "column_name"))
```


Get rid of punctuation signs from the column labels:

```r
head(column_labels$column_name)
```

```
## [1] tBodyAcc-mean()-X tBodyAcc-mean()-Y tBodyAcc-mean()-Z tBodyAcc-std()-X 
## [5] tBodyAcc-std()-Y  tBodyAcc-std()-Z 
## 477 Levels: angle(X,gravityMean) ... tGravityAccMag-std()
```

```r
column_labels$column_name <- gsub("[[:punct:]]", "", column_labels$column_name)
head(column_labels$column_name)
```

```
## [1] "tBodyAccmeanX" "tBodyAccmeanY" "tBodyAccmeanZ" "tBodyAccstdX" 
## [5] "tBodyAccstdY"  "tBodyAccstdZ"
```


Find all column names wich contains the string "mean" and exclude those which contains "meanFreq":

```r
mean_cols <- grep("mean", column_labels$column_name)
x_meanFreq <- grep("meanFreq", column_labels$column_name)
mean_cols <- setdiff(mean_cols, x_meanFreq)
```


Find all column names wich contains the string "std" and union them with the columns which contains mean. Variable "all_cols" is a vector with the column number of the measurements with mean and standard deviation on the original data set:

```r
std_cols <- grep("std", column_labels$column_name)
all_cols <- union(mean_cols, std_cols)
head(all_cols)
```

```
## [1]  1  2  3 41 42 43
```


Clean labels for "mean" and "std":

```r
head(column_labels$column_name)
```

```
## [1] "tBodyAccmeanX" "tBodyAccmeanY" "tBodyAccmeanZ" "tBodyAccstdX" 
## [5] "tBodyAccstdY"  "tBodyAccstdZ"
```

```r
column_labels$column_name <- gsub("mean", "_mean_", column_labels$column_name)
column_labels$column_name <- gsub("std", "_stddev_", column_labels$column_name)
head(column_labels$column_name)
```

```
## [1] "tBodyAcc_mean_X"   "tBodyAcc_mean_Y"   "tBodyAcc_mean_Z"  
## [4] "tBodyAcc_stddev_X" "tBodyAcc_stddev_Y" "tBodyAcc_stddev_Z"
```


Read files with training and test data, append appropriate column names for each data set:

```r
activity_test <- read.table("test/y_test.txt", col.names = c("activity_ID"))
dim(activity_test)
```

```
## [1] 2947    1
```

```r
measures_test <- read.table("test/x_test.txt", col.names = column_labels$column_name)
dim(measures_test)
```

```
## [1] 2947  561
```

```r
subject_test <- read.table("test/subject_test.txt", col.names = c("subject_ID"))
dim(subject_test)
```

```
## [1] 2947    1
```

```r
activity_train <- read.table("train/y_train.txt", col.names = c("activity_ID"))
dim(activity_train)
```

```
## [1] 7352    1
```

```r
measures_train <- read.table("train/x_train.txt", col.names = column_labels$column_name)
dim(measures_train)
```

```
## [1] 7352  561
```

```r
subject_train <- read.table("train/subject_train.txt", col.names = c("subject_ID"))
dim(subject_train)
```

```
## [1] 7352    1
```


Subset the columns of the training and test data in order to extract only the measurements on the mean and standard deviation:

```r
measures_test_sub <- measures_test[, all_cols]
dim(measures_test_sub)
```

```
## [1] 2947   66
```

```r
measures_train_sub <- measures_train[, all_cols]
dim(measures_train_sub)
```

```
## [1] 7352   66
```


Append the columns with activity_ID and subject_ID to the training and test data frames:

```r
measures_test_act <- cbind(activity_test, measures_test_sub, subject_test)
dim(measures_test_act)
```

```
## [1] 2947   68
```

```r
head(measures_test_act)
```

```
##   activity_ID tBodyAcc_mean_X tBodyAcc_mean_Y tBodyAcc_mean_Z
## 1           5          0.2572        -0.02329        -0.01465
## 2           5          0.2860        -0.01316        -0.11908
## 3           5          0.2755        -0.02605        -0.11815
## 4           5          0.2703        -0.03261        -0.11752
## 5           5          0.2748        -0.02785        -0.12953
## 6           5          0.2792        -0.01862        -0.11390
##   tGravityAcc_mean_X tGravityAcc_mean_Y tGravityAcc_mean_Z
## 1             0.9365            -0.2827             0.1153
## 2             0.9274            -0.2892             0.1526
## 3             0.9299            -0.2875             0.1461
## 4             0.9289            -0.2934             0.1429
## 5             0.9266            -0.3030             0.1383
## 6             0.9257            -0.3089             0.1306
##   tBodyAccJerk_mean_X tBodyAccJerk_mean_Y tBodyAccJerk_mean_Z
## 1             0.07205            0.045754           -0.106043
## 2             0.07018           -0.017876           -0.001721
## 3             0.06937           -0.004908           -0.013673
## 4             0.07485            0.032274            0.012141
## 5             0.07838            0.022277            0.002748
## 6             0.07598            0.017519            0.008208
##   tBodyGyro_mean_X tBodyGyro_mean_Y tBodyGyro_mean_Z tBodyGyroJerk_mean_X
## 1         0.119976         -0.09179          0.18963             -0.20490
## 2        -0.001552         -0.18729          0.18071             -0.13867
## 3        -0.048213         -0.16628          0.15417             -0.09781
## 4        -0.056642         -0.12602          0.11834             -0.10223
## 5        -0.059992         -0.08472          0.07866             -0.09185
## 6        -0.039698         -0.06683          0.07055             -0.09274
##   tBodyGyroJerk_mean_Y tBodyGyroJerk_mean_Z tBodyAccMag_mean_
## 1             -0.17449             -0.09339           -0.8669
## 2             -0.02580             -0.07142           -0.9690
## 3             -0.03421             -0.06003           -0.9762
## 4             -0.04471             -0.05344           -0.9743
## 5             -0.02901             -0.06124           -0.9758
## 6             -0.03214             -0.07258           -0.9817
##   tGravityAccMag_mean_ tBodyAccJerkMag_mean_ tBodyGyroMag_mean_
## 1              -0.8669               -0.9298            -0.7955
## 2              -0.9690               -0.9737            -0.8984
## 3              -0.9762               -0.9816            -0.9392
## 4              -0.9743               -0.9827            -0.9472
## 5              -0.9758               -0.9869            -0.9574
## 6              -0.9817               -0.9873            -0.9697
##   tBodyGyroJerkMag_mean_ fBodyAcc_mean_X fBodyAcc_mean_Y fBodyAcc_mean_Z
## 1                -0.9252         -0.9185         -0.9182         -0.7891
## 2                -0.9734         -0.9609         -0.9644         -0.9567
## 3                -0.9867         -0.9919         -0.9650         -0.9669
## 4                -0.9888         -0.9930         -0.9683         -0.9669
## 5                -0.9901         -0.9924         -0.9692         -0.9797
## 6                -0.9878         -0.9938         -0.9707         -0.9756
##   fBodyAccJerk_mean_X fBodyAccJerk_mean_Y fBodyAccJerk_mean_Z
## 1             -0.8996             -0.9375             -0.9236
## 2             -0.9435             -0.9692             -0.9734
## 3             -0.9910             -0.9734             -0.9717
## 4             -0.9905             -0.9725             -0.9703
## 5             -0.9915             -0.9798             -0.9835
## 6             -0.9938             -0.9790             -0.9861
##   fBodyGyro_mean_X fBodyGyro_mean_Y fBodyGyro_mean_Z fBodyAccMag_mean_
## 1          -0.8236          -0.8079          -0.9179           -0.7909
## 2          -0.9225          -0.9265          -0.9682           -0.9541
## 3          -0.9728          -0.9808          -0.9721           -0.9756
## 4          -0.9715          -0.9813          -0.9667           -0.9734
## 5          -0.9764          -0.9804          -0.9688           -0.9777
## 6          -0.9797          -0.9805          -0.9602           -0.9780
##   fBodyBodyAccJerkMag_mean_ fBodyBodyGyroMag_mean_
## 1                   -0.8951                -0.7706
## 2                   -0.9454                -0.9245
## 3                   -0.9711                -0.9752
## 4                   -0.9717                -0.9763
## 5                   -0.9875                -0.9770
## 6                   -0.9913                -0.9770
##   fBodyBodyGyroJerkMag_mean_ tBodyAcc_stddev_X tBodyAcc_stddev_Y
## 1                    -0.8902           -0.9384           -0.9201
## 2                    -0.9520           -0.9754           -0.9675
## 3                    -0.9857           -0.9938           -0.9699
## 4                    -0.9856           -0.9947           -0.9733
## 5                    -0.9905           -0.9939           -0.9674
## 6                    -0.9887           -0.9945           -0.9704
##   tBodyAcc_stddev_Z tGravityAcc_stddev_X tGravityAcc_stddev_Y
## 1           -0.6677              -0.9254              -0.9370
## 2           -0.9450              -0.9891              -0.9839
## 3           -0.9627              -0.9959              -0.9883
## 4           -0.9671              -0.9931              -0.9704
## 5           -0.9783              -0.9956              -0.9710
## 6           -0.9653              -0.9988              -0.9907
##   tGravityAcc_stddev_Z tBodyAccJerk_stddev_X tBodyAccJerk_stddev_Y
## 1              -0.5643               -0.9067               -0.9380
## 2              -0.9648               -0.9492               -0.9727
## 3              -0.9816               -0.9911               -0.9714
## 4              -0.9916               -0.9908               -0.9729
## 5              -0.9681               -0.9921               -0.9787
## 6              -0.9712               -0.9938               -0.9791
##   tBodyAccJerk_stddev_Z tBodyGyro_stddev_X tBodyGyro_stddev_Y
## 1               -0.9359            -0.8831            -0.8162
## 2               -0.9777            -0.9256            -0.9296
## 3               -0.9729            -0.9730            -0.9785
## 4               -0.9759            -0.9678            -0.9751
## 5               -0.9866            -0.9747            -0.9780
## 6               -0.9876            -0.9799            -0.9765
##   tBodyGyro_stddev_Z tBodyGyroJerk_stddev_X tBodyGyroJerk_stddev_Y
## 1            -0.9409                -0.9012                -0.9109
## 2            -0.9676                -0.9623                -0.9563
## 3            -0.9756                -0.9842                -0.9879
## 4            -0.9632                -0.9842                -0.9896
## 5            -0.9676                -0.9885                -0.9919
## 6            -0.9635                -0.9894                -0.9895
##   tBodyGyroJerk_stddev_Z tBodyAccMag_stddev_ tGravityAccMag_stddev_
## 1                -0.9393             -0.7052                -0.7052
## 2                -0.9813             -0.9539                -0.9539
## 3                -0.9762             -0.9791                -0.9791
## 4                -0.9807             -0.9770                -0.9770
## 5                -0.9820             -0.9769                -0.9769
## 6                -0.9778             -0.9777                -0.9777
##   tBodyAccJerkMag_stddev_ tBodyGyroMag_stddev_ tBodyGyroJerkMag_stddev_
## 1                 -0.8960              -0.7621                  -0.8943
## 2                 -0.9410              -0.9109                  -0.9441
## 3                 -0.9714              -0.9718                  -0.9844
## 4                 -0.9748              -0.9704                  -0.9856
## 5                 -0.9889              -0.9695                  -0.9904
## 6                 -0.9920              -0.9733                  -0.9890
##   fBodyAcc_stddev_X fBodyAcc_stddev_Y fBodyAcc_stddev_Z
## 1           -0.9483           -0.9251           -0.6363
## 2           -0.9843           -0.9702           -0.9419
## 3           -0.9948           -0.9737           -0.9623
## 4           -0.9956           -0.9769           -0.9690
## 5           -0.9945           -0.9675           -0.9782
## 6           -0.9946           -0.9710           -0.9614
##   fBodyAccJerk_stddev_X fBodyAccJerk_stddev_Y fBodyAccJerk_stddev_Z
## 1               -0.9244               -0.9432               -0.9479
## 2               -0.9616               -0.9800               -0.9808
## 3               -0.9919               -0.9710               -0.9723
## 4               -0.9920               -0.9754               -0.9806
## 5               -0.9936               -0.9787               -0.9885
## 6               -0.9945               -0.9808               -0.9876
##   fBodyGyro_stddev_X fBodyGyro_stddev_Y fBodyGyro_stddev_Z
## 1            -0.9033            -0.8227            -0.9562
## 2            -0.9271            -0.9320            -0.9701
## 3            -0.9732            -0.9772            -0.9791
## 4            -0.9672            -0.9719            -0.9653
## 5            -0.9744            -0.9766            -0.9700
## 6            -0.9800            -0.9742            -0.9678
##   fBodyAccMag_stddev_ fBodyBodyAccJerkMag_stddev_ fBodyBodyGyroMag_stddev_
## 1             -0.7111                     -0.8964                  -0.7971
## 2             -0.9597                     -0.9342                  -0.9168
## 3             -0.9838                     -0.9703                  -0.9740
## 4             -0.9821                     -0.9785                  -0.9712
## 5             -0.9788                     -0.9897                  -0.9696
## 6             -0.9799                     -0.9917                  -0.9751
##   fBodyBodyGyroJerkMag_stddev_ subject_ID
## 1                      -0.9073          2
## 2                      -0.9382          2
## 3                      -0.9833          2
## 4                      -0.9858          2
## 5                      -0.9906          2
## 6                      -0.9898          2
```

```r
measures_train_act <- cbind(activity_train, measures_train_sub, subject_train)
dim(measures_train_act)
```

```
## [1] 7352   68
```

```r
head(measures_train_act)
```

```
##   activity_ID tBodyAcc_mean_X tBodyAcc_mean_Y tBodyAcc_mean_Z
## 1           5          0.2886        -0.02029         -0.1329
## 2           5          0.2784        -0.01641         -0.1235
## 3           5          0.2797        -0.01947         -0.1135
## 4           5          0.2792        -0.02620         -0.1233
## 5           5          0.2766        -0.01657         -0.1154
## 6           5          0.2772        -0.01010         -0.1051
##   tGravityAcc_mean_X tGravityAcc_mean_Y tGravityAcc_mean_Z
## 1             0.9634            -0.1408            0.11537
## 2             0.9666            -0.1416            0.10938
## 3             0.9669            -0.1420            0.10188
## 4             0.9676            -0.1440            0.09985
## 5             0.9682            -0.1488            0.09449
## 6             0.9679            -0.1482            0.09191
##   tBodyAccJerk_mean_X tBodyAccJerk_mean_Y tBodyAccJerk_mean_Z
## 1             0.07800            0.005001           -0.067831
## 2             0.07401            0.005771            0.029377
## 3             0.07364            0.003104           -0.009046
## 4             0.07732            0.020058           -0.009865
## 5             0.07344            0.019122            0.016780
## 6             0.07793            0.018684            0.009344
##   tBodyGyro_mean_X tBodyGyro_mean_Y tBodyGyro_mean_Z tBodyGyroJerk_mean_X
## 1        -0.006101         -0.03136          0.10773             -0.09917
## 2        -0.016112         -0.08389          0.10058             -0.11050
## 3        -0.031698         -0.10234          0.09613             -0.10849
## 4        -0.043410         -0.09139          0.08554             -0.09117
## 5        -0.033960         -0.07471          0.07739             -0.09077
## 6        -0.028776         -0.07039          0.07901             -0.09425
##   tBodyGyroJerk_mean_Y tBodyGyroJerk_mean_Z tBodyAccMag_mean_
## 1             -0.05552             -0.06199           -0.9594
## 2             -0.04482             -0.05924           -0.9793
## 3             -0.04241             -0.05583           -0.9837
## 4             -0.03633             -0.06046           -0.9865
## 5             -0.03763             -0.05829           -0.9928
## 6             -0.04336             -0.04194           -0.9943
##   tGravityAccMag_mean_ tBodyAccJerkMag_mean_ tBodyGyroMag_mean_
## 1              -0.9594               -0.9933            -0.9690
## 2              -0.9793               -0.9913            -0.9807
## 3              -0.9837               -0.9885            -0.9763
## 4              -0.9865               -0.9931            -0.9821
## 5              -0.9928               -0.9935            -0.9852
## 6              -0.9943               -0.9930            -0.9859
##   tBodyGyroJerkMag_mean_ fBodyAcc_mean_X fBodyAcc_mean_Y fBodyAcc_mean_Z
## 1                -0.9942         -0.9948         -0.9830         -0.9393
## 2                -0.9951         -0.9975         -0.9769         -0.9735
## 3                -0.9934         -0.9936         -0.9725         -0.9833
## 4                -0.9955         -0.9955         -0.9836         -0.9911
## 5                -0.9958         -0.9973         -0.9823         -0.9884
## 6                -0.9953         -0.9967         -0.9869         -0.9927
##   fBodyAccJerk_mean_X fBodyAccJerk_mean_Y fBodyAccJerk_mean_Z
## 1             -0.9923             -0.9872             -0.9897
## 2             -0.9950             -0.9813             -0.9897
## 3             -0.9910             -0.9816             -0.9876
## 4             -0.9944             -0.9887             -0.9914
## 5             -0.9963             -0.9888             -0.9906
## 6             -0.9949             -0.9882             -0.9902
##   fBodyGyro_mean_X fBodyGyro_mean_Y fBodyGyro_mean_Z fBodyAccMag_mean_
## 1          -0.9866          -0.9818          -0.9895           -0.9522
## 2          -0.9774          -0.9925          -0.9896           -0.9809
## 3          -0.9754          -0.9937          -0.9868           -0.9878
## 4          -0.9871          -0.9936          -0.9872           -0.9875
## 5          -0.9824          -0.9930          -0.9887           -0.9936
## 6          -0.9849          -0.9928          -0.9808           -0.9948
##   fBodyBodyAccJerkMag_mean_ fBodyBodyGyroMag_mean_
## 1                   -0.9937                -0.9801
## 2                   -0.9903                -0.9883
## 3                   -0.9893                -0.9893
## 4                   -0.9928                -0.9894
## 5                   -0.9955                -0.9914
## 6                   -0.9947                -0.9905
##   fBodyBodyGyroJerkMag_mean_ tBodyAcc_stddev_X tBodyAcc_stddev_Y
## 1                    -0.9920           -0.9953           -0.9831
## 2                    -0.9959           -0.9982           -0.9753
## 3                    -0.9950           -0.9954           -0.9672
## 4                    -0.9952           -0.9961           -0.9834
## 5                    -0.9951           -0.9981           -0.9808
## 6                    -0.9951           -0.9973           -0.9905
##   tBodyAcc_stddev_Z tGravityAcc_stddev_X tGravityAcc_stddev_Y
## 1           -0.9135              -0.9852              -0.9817
## 2           -0.9603              -0.9974              -0.9894
## 3           -0.9789              -0.9996              -0.9929
## 4           -0.9907              -0.9966              -0.9814
## 5           -0.9905              -0.9984              -0.9881
## 6           -0.9954              -0.9990              -0.9868
##   tGravityAcc_stddev_Z tBodyAccJerk_stddev_X tBodyAccJerk_stddev_Y
## 1              -0.8776               -0.9935               -0.9884
## 2              -0.9316               -0.9955               -0.9811
## 3              -0.9929               -0.9907               -0.9810
## 4              -0.9785               -0.9927               -0.9876
## 5              -0.9787               -0.9964               -0.9884
## 6              -0.9973               -0.9948               -0.9887
##   tBodyAccJerk_stddev_Z tBodyGyro_stddev_X tBodyGyro_stddev_Y
## 1               -0.9936            -0.9853            -0.9766
## 2               -0.9918            -0.9831            -0.9890
## 3               -0.9897            -0.9763            -0.9936
## 4               -0.9935            -0.9914            -0.9924
## 5               -0.9925            -0.9852            -0.9924
## 6               -0.9923            -0.9852            -0.9921
##   tBodyGyro_stddev_Z tBodyGyroJerk_stddev_X tBodyGyroJerk_stddev_Y
## 1            -0.9922                -0.9921                -0.9925
## 2            -0.9891                -0.9899                -0.9973
## 3            -0.9864                -0.9885                -0.9956
## 4            -0.9876                -0.9911                -0.9966
## 5            -0.9874                -0.9914                -0.9965
## 6            -0.9831                -0.9916                -0.9960
##   tBodyGyroJerk_stddev_Z tBodyAccMag_stddev_ tGravityAccMag_stddev_
## 1                -0.9921             -0.9506                -0.9506
## 2                -0.9939             -0.9761                -0.9761
## 3                -0.9915             -0.9880                -0.9880
## 4                -0.9933             -0.9864                -0.9864
## 5                -0.9945             -0.9913                -0.9913
## 6                -0.9931             -0.9952                -0.9952
##   tBodyAccJerkMag_stddev_ tBodyGyroMag_stddev_ tBodyGyroJerkMag_stddev_
## 1                 -0.9943              -0.9643                  -0.9914
## 2                 -0.9917              -0.9838                  -0.9961
## 3                 -0.9904              -0.9861                  -0.9951
## 4                 -0.9934              -0.9874                  -0.9953
## 5                 -0.9959              -0.9891                  -0.9953
## 6                 -0.9954              -0.9864                  -0.9952
##   fBodyAcc_stddev_X fBodyAcc_stddev_Y fBodyAcc_stddev_Z
## 1           -0.9954           -0.9831           -0.9062
## 2           -0.9987           -0.9749           -0.9554
## 3           -0.9963           -0.9655           -0.9770
## 4           -0.9963           -0.9832           -0.9902
## 5           -0.9986           -0.9801           -0.9919
## 6           -0.9976           -0.9923           -0.9970
##   fBodyAccJerk_stddev_X fBodyAccJerk_stddev_Y fBodyAccJerk_stddev_Z
## 1               -0.9958               -0.9909               -0.9971
## 2               -0.9967               -0.9821               -0.9926
## 3               -0.9912               -0.9814               -0.9904
## 4               -0.9914               -0.9869               -0.9944
## 5               -0.9969               -0.9886               -0.9929
## 6               -0.9952               -0.9902               -0.9931
##   fBodyGyro_stddev_X fBodyGyro_stddev_Y fBodyGyro_stddev_Z
## 1            -0.9850            -0.9739            -0.9940
## 2            -0.9849            -0.9872            -0.9898
## 3            -0.9766            -0.9934            -0.9873
## 4            -0.9928            -0.9916            -0.9887
## 5            -0.9860            -0.9920            -0.9879
## 6            -0.9853            -0.9917            -0.9854
##   fBodyAccMag_stddev_ fBodyBodyAccJerkMag_stddev_ fBodyBodyGyroMag_stddev_
## 1             -0.9561                     -0.9938                  -0.9613
## 2             -0.9759                     -0.9920                  -0.9833
## 3             -0.9890                     -0.9909                  -0.9860
## 4             -0.9867                     -0.9917                  -0.9878
## 5             -0.9901                     -0.9944                  -0.9891
## 6             -0.9953                     -0.9952                  -0.9859
##   fBodyBodyGyroJerkMag_stddev_ subject_ID
## 1                      -0.9907          1
## 2                      -0.9964          1
## 3                      -0.9951          1
## 4                      -0.9952          1
## 5                      -0.9955          1
## 6                      -0.9952          1
```


Merge the training and test data variables into 1 data frame named "all_measures":

```r
all_measures <- rbind(measures_test_act, measures_train_act)
dim(all_measures)
```

```
## [1] 10299    68
```


Perform an SQL join to include labels for each activity_ID. The resulting data frame meets the characteristics of tidy data:
* Each variable in one column
* Each different observation in one row
* A row at the top with variable names
* Variable names are human readable

```r
tidy_measures <- sqldf("select a.activity_name, m.* from activity_labels as a, all_measures m where a.activity_ID = m.activity_ID")
```

```
## Loading required package: tcltk
```

```r
dim(tidy_measures)
```

```
## [1] 10299    69
```

```r
head(tidy_measures[, c(1:5, 65:69)], 20)
```

```
##    activity_name activity_ID tBodyAcc_mean_X tBodyAcc_mean_Y
## 1        WALKING           1          0.1215      -0.0319019
## 2        WALKING           1          0.1311      -0.0361046
## 3        WALKING           1          0.1350      -0.0053608
## 4        WALKING           1          0.1378      -0.0106515
## 5        WALKING           1          0.1417      -0.0078034
## 6        WALKING           1          0.1472      -0.0141944
## 7        WALKING           1          0.1475      -0.0238848
## 8        WALKING           1          0.1529      -0.0722100
## 9        WALKING           1          0.1547      -0.0320368
## 10       WALKING           1          0.1562      -0.0496146
## 11       WALKING           1          0.1569      -0.0021175
## 12       WALKING           1          0.1626      -0.0368599
## 13       WALKING           1          0.1626       0.0057187
## 14       WALKING           1          0.1644      -0.0239891
## 15       WALKING           1          0.1657      -0.0145335
## 16       WALKING           1          0.1680      -0.0091353
## 17       WALKING           1          0.1683      -0.0186195
## 18       WALKING           1          0.1687      -0.0055779
## 19       WALKING           1          0.1696      -0.0088641
## 20       WALKING           1          0.1719       0.0005195
##    tBodyAcc_mean_Z fBodyAccMag_stddev_ fBodyBodyAccJerkMag_stddev_
## 1        -0.005196             -0.3601                   -0.104839
## 2        -0.178336             -0.5249                   -0.329774
## 3        -0.072839             -0.4684                   -0.324689
## 4        -0.081164             -0.4622                   -0.238561
## 5        -0.132632             -0.3223                    0.326975
## 6        -0.071223             -0.3849                   -0.194247
## 7        -0.117789             -0.3276                   -0.026209
## 8        -0.062104             -0.3470                    0.012697
## 9        -0.052296             -0.5770                   -0.413920
## 10       -0.112901             -0.3499                    0.105957
## 11       -0.085928             -0.4514                   -0.296906
## 12       -0.093059             -0.3657                    0.003777
## 13       -0.092314             -0.3803                   -0.136136
## 14       -0.042246             -0.4881                   -0.485824
## 15       -0.119659             -0.3777                   -0.072572
## 16       -0.110908             -0.4032                   -0.105120
## 17       -0.054696             -0.4806                   -0.435915
## 18       -0.100539             -0.6052                   -0.314084
## 19       -0.123126             -0.4736                   -0.353147
## 20       -0.107163             -0.4637                   -0.138527
##    fBodyBodyGyroMag_stddev_ fBodyBodyGyroJerkMag_stddev_ subject_ID
## 1                   -0.4147                      -0.6607         29
## 2                   -0.2616                      -0.1005         23
## 3                   -0.4875                      -0.6487         29
## 4                   -0.4797                      -0.7069         29
## 5                   -0.5518                      -0.5984         10
## 6                   -0.3473                      -0.6911         29
## 7                   -0.5799                      -0.6155         10
## 8                   -0.4130                      -0.5022         13
## 9                   -0.5106                      -0.7590         11
## 10                  -0.3202                      -0.2177          1
## 11                  -0.4666                      -0.6992         29
## 12                  -0.5045                      -0.4516         21
## 13                  -0.4358                      -0.6167         29
## 14                  -0.5612                      -0.6199         28
## 15                  -0.4217                      -0.5779         29
## 16                  -0.3297                      -0.1439          7
## 17                  -0.3443                      -0.3511         28
## 18                  -0.7072                      -0.6893         26
## 19                  -0.3574                      -0.3749         28
## 20                  -0.4754                      -0.1477          6
```

```r
tail(tidy_measures[, c(1:5, 65:69)], 20)
```

```
##       activity_name activity_ID tBodyAcc_mean_X tBodyAcc_mean_Y
## 10280        LAYING           6          0.4779        0.264443
## 10281        LAYING           6          0.4788       -0.022650
## 10282        LAYING           6          0.4844       -0.006595
## 10283        LAYING           6          0.4868        0.036752
## 10284        LAYING           6          0.4883       -0.005456
## 10285        LAYING           6          0.4908       -0.019362
## 10286        LAYING           6          0.5038       -0.544314
## 10287        LAYING           6          0.5157       -0.030471
## 10288        LAYING           6          0.5168        0.003408
## 10289        LAYING           6          0.5283        0.013857
## 10290        LAYING           6          0.5335        0.043680
## 10291        LAYING           6          0.5382       -0.043285
## 10292        LAYING           6          0.5439        0.373293
## 10293        LAYING           6          0.5638        0.047432
## 10294        LAYING           6          0.6254        0.018359
## 10295        LAYING           6          0.6326        1.000000
## 10296        LAYING           6          0.6719       -0.014351
## 10297        LAYING           6          0.6803        0.594513
## 10298        LAYING           6          0.6928        0.064792
## 10299        LAYING           6          1.0000        0.535820
##       tBodyAcc_mean_Z fBodyAccMag_stddev_ fBodyBodyAccJerkMag_stddev_
## 10280        -0.25606            -0.03752                     -0.6985
## 10281        -0.08283            -0.67943                     -0.8831
## 10282        -0.16803            -0.74716                     -0.9813
## 10283        -0.18034            -0.80343                     -0.8691
## 10284        -0.57475            -0.75160                     -0.9783
## 10285        -0.30709            -0.64530                     -0.8834
## 10286        -0.29583             0.02672                     -0.9615
## 10287        -0.21497            -0.81014                     -0.8841
## 10288        -0.11269            -0.78754                     -0.9823
## 10289        -0.13100            -0.84203                     -0.9488
## 10290        -0.15781            -0.55510                     -0.6926
## 10291        -0.12260            -0.85861                     -0.9214
## 10292        -0.42798            -0.86243                     -0.9837
## 10293        -0.34697            -0.93626                     -0.9774
## 10294        -0.20197            -0.57880                     -0.9744
## 10295        -0.44393            -0.30958                     -0.9564
## 10296        -0.15990            -0.54071                     -0.6588
## 10297        -0.57420            -0.57051                     -0.9312
## 10298        -0.50895            -0.56994                     -0.9294
## 10299        -0.75753             0.12753                     -0.9591
##       fBodyBodyGyroMag_stddev_ fBodyBodyGyroJerkMag_stddev_ subject_ID
## 10280                  -0.6534                      -0.8010         22
## 10281                  -0.8033                      -0.9351         13
## 10282                  -0.8284                      -0.9893         29
## 10283                  -0.6860                      -0.8797          8
## 10284                  -0.8890                      -0.9825         25
## 10285                  -0.6622                      -0.8784          6
## 10286                  -0.8358                      -0.9641         25
## 10287                  -0.6820                      -0.8298          6
## 10288                  -0.9394                      -0.9758         19
## 10289                  -0.8939                      -0.9616         19
## 10290                  -0.5183                      -0.8622         22
## 10291                  -0.7427                      -0.9520         15
## 10292                  -0.9307                      -0.9824         25
## 10293                  -0.9304                      -0.9737         25
## 10294                  -0.7528                      -0.9856         22
## 10295                  -0.4685                      -0.9649         25
## 10296                  -0.5365                      -0.7350         10
## 10297                  -0.7417                      -0.9461         25
## 10298                  -0.8352                      -0.8985         25
## 10299                  -0.7560                      -0.9699         25
```


Build and execute a new SQL SELECT statement to summarize the data by subject_ID and activity name:

```r
measures_avg <- paste(", avg(", names(tidy_measures[3:68]), ")", sep = "", collapse = " ")
sqlstmt <- paste("select subject_ID, activity_name", measures_avg, "from tidy_measures group by subject_id, activity_name")
tidy_measures_avg <- sqldf(sqlstmt)
dim(tidy_measures_avg)
```

```
## [1] 180  68
```

```r
head(tidy_measures_avg[, c(1:5, 65:68)], 10)
```

```
##    subject_ID      activity_name avg(tBodyAcc_mean_X) avg(tBodyAcc_mean_Y)
## 1           1             LAYING               0.2216            -0.040514
## 2           1            SITTING               0.2612            -0.001308
## 3           1           STANDING               0.2789            -0.016138
## 4           1            WALKING               0.2773            -0.017384
## 5           1 WALKING_DOWNSTAIRS               0.2892            -0.009919
## 6           1   WALKING_UPSTAIRS               0.2555            -0.023953
## 7           2             LAYING               0.2814            -0.018159
## 8           2            SITTING               0.2771            -0.015688
## 9           2           STANDING               0.2779            -0.018421
## 10          2            WALKING               0.2764            -0.018595
##    avg(tBodyAcc_mean_Z) avg(fBodyAccMag_stddev_)
## 1               -0.1132                  -0.7983
## 2               -0.1045                  -0.9284
## 3               -0.1106                  -0.9823
## 4               -0.1111                  -0.3980
## 5               -0.1076                  -0.1865
## 6               -0.0973                  -0.4163
## 7               -0.1072                  -0.9751
## 8               -0.1092                  -0.9556
## 9               -0.1059                  -0.9605
## 10              -0.1055                  -0.5771
##    avg(fBodyBodyAccJerkMag_stddev_) avg(fBodyBodyGyroMag_stddev_)
## 1                           -0.9218                       -0.8243
## 2                           -0.9816                       -0.9322
## 3                           -0.9925                       -0.9785
## 4                           -0.1035                       -0.3210
## 5                           -0.1041                       -0.3984
## 6                           -0.5331                       -0.1830
## 7                           -0.9846                       -0.9611
## 8                           -0.9841                       -0.9614
## 9                           -0.9752                       -0.9568
## 10                          -0.1641                       -0.6518
##    avg(fBodyBodyGyroJerkMag_stddev_)
## 1                            -0.9327
## 2                            -0.9870
## 3                            -0.9947
## 4                            -0.3816
## 5                            -0.3919
## 6                            -0.6939
## 7                            -0.9895
## 8                            -0.9896
## 9                            -0.9778
## 10                           -0.5581
```

```r
tail(tidy_measures_avg[, c(1:5, 65:68)], 10)
```

```
##     subject_ID      activity_name avg(tBodyAcc_mean_X)
## 171         29           STANDING               0.2780
## 172         29            WALKING               0.2720
## 173         29 WALKING_DOWNSTAIRS               0.2931
## 174         29   WALKING_UPSTAIRS               0.2654
## 175         30             LAYING               0.2810
## 176         30            SITTING               0.2683
## 177         30           STANDING               0.2771
## 178         30            WALKING               0.2764
## 179         30 WALKING_DOWNSTAIRS               0.2832
## 180         30   WALKING_UPSTAIRS               0.2714
##     avg(tBodyAcc_mean_Y) avg(tBodyAcc_mean_Z) avg(fBodyAccMag_stddev_)
## 171            -0.017261             -0.10866                 -0.98225
## 172            -0.016292             -0.10663                 -0.39326
## 173            -0.014941             -0.09813                 -0.03309
## 174            -0.029947             -0.11800                 -0.15599
## 175            -0.019449             -0.10366                 -0.96405
## 176            -0.008047             -0.09952                 -0.94354
## 177            -0.017016             -0.10876                 -0.92173
## 178            -0.017588             -0.09862                 -0.46985
## 179            -0.017438             -0.09998                 -0.17854
## 180            -0.025331             -0.12470                 -0.39451
##     avg(fBodyBodyAccJerkMag_stddev_) avg(fBodyBodyGyroMag_stddev_)
## 171                         -0.99033                      -0.97594
## 172                         -0.16951                      -0.42916
## 173                         -0.07977                      -0.32302
## 174                         -0.28058                      -0.07433
## 175                         -0.96809                      -0.95264
## 176                         -0.98529                      -0.95951
## 177                         -0.94664                      -0.88887
## 178                         -0.36654                      -0.33154
## 179                         -0.13312                      -0.25236
## 180                         -0.58088                      -0.15147
##     avg(fBodyBodyGyroJerkMag_stddev_)
## 171                           -0.9915
## 172                           -0.6187
## 173                           -0.6267
## 174                           -0.7565
## 175                           -0.9755
## 176                           -0.9909
## 177                           -0.9550
## 178                           -0.5786
## 179                           -0.6455
## 180                           -0.7913
```

```r
write.csv(tidy_measures_avg, file("tidy_measures_avg.csv"))
```
 
