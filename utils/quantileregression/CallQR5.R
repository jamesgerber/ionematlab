
# Jamie code to carry out quantile regression using quantreg package in R. 
# this reads in datafile.csv, which must evaulate to an array whose first column is Yield and whose second column is weights.  The next N columns are sent in as variables to the QR analysis.

# R4 - covariance matrix

# first read in datafile.csv file with y,x1,x2,x3 ... etc.

#setwd("/Users/jsgerber/sandbox/jsg131_yieldgapsovertime_withQR_and_bins")
#  setwd("/Users/jsgerber/sandbox/jsg131_clean_ygot")
# setwd("D:\\Workspaces\\Matlab Workspace") 
#############
####Data#####
#############


library(R.matlab)
newdata<-readMat("transferdatatoR.mat")
data2<-newdata$BigArray

tauvals<-newdata$tauvalues
tt=tauvals[1,1]
##data<-read.csv("datafile.csv")

Ncols<-dim(data2)[2]
#Yield<-data[,1]
Yield<-data2[,1]
W<-data2[,2]

# definining named variables and creating the formula

compoundExpression <- "Yield~var1"
eval(parse(text=paste("var",as.character(1),"<-data2[,3]",sep="")))
for (j in 4:Ncols)
{
  #print(j)	
  eval(parse(text=paste("var",as.character(j-2),"<-data2[,j]",sep="")))
  eval(parse(text=paste("compoundExpression<-paste(compoundExpression,\"+\",\"var",as.character(j-2),"\",collapse=\"\",sep=\"\")",collapse="", sep="")))
}
# print(compoundExpression)
# print output: Yield~var1+var2+var3+...+varn
alphaval<-newdata$alphavalue

aa=alphaval[1,1]
####Tested quantiles####
library("quantreg")


#method options:
#
# default "br"  methodsflag=0
#  "larger problems"  Frisch-Newton   "fn" methodsflag=1
#  "pfn" with pre-processing methodsflag=2
#  "sfn"  if sparseness  methodsflag=3


methodsflag<-newdata$algorithmflag




if (methodsflag==1){
  methodstr<-"fn"
} else if (methodsflag==2){
  methodstr<-"pfn"
} else if (methodsflag==3){
  methodstr<-"sfn"
}else{ 
  #Defaults to "br"
  methodstr<-"br"
}


if (methodstr=="br") {
  Fit.i<-rq(as.formula(compoundExpression),tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
  
} else {
  Fit.i<-rq(as.formula(compoundExpression),tau=tt,weight=W,method=methodstr)
  
}



Theta<-coef(Fit.i)
print(Theta)
write(Theta,file='output.txt',ncolumns=1)
AICValue<-AIC(Fit.i)
BICValue<-BIC(Fit.i)
print(BICValue)
write(AICValue,file='AICValue.txt',ncolumns=1);
write(BICValue,file='BICValue.txt',ncolumns=1);


x <- summary.rq(Fit.i,se="nid", covariance=TRUE)
covmatrix <- x$cov
write(covmatrix,'covmatrix.txt',ncolumns=1)





