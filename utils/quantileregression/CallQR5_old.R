
# Jamie code to carry out quantile regression using quantreg package in R. 
# this reads in datafile.csv, which must evaulate to an array whose first column is Yield and whose second column is weights.  The next N columns are sent in as variables to the QR analysis.

# R4 - covariance matrix

# first read in datafile.csv file with y,x1,x2,x3 ... etc.

#setwd("/Users/jsgerber/sandbox/jsg131_yieldgapsovertime_withQR_and_bins")
#  setwd("/Users/jsgerber/sandbox/jsg131_clean_ygot")

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

# definining named variables
for (j in 3:Ncols)
{
	#print(j)	
eval(parse(text=paste("var",as.character(j-2),"<-data2[,j]",sep="")))
}
                   
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


if (methodsflag==0)
methodstr<-"br"

if (methodsflag==1)
methodstr<-"fn"

if (methodsflag==2)
methodstr<-"pfn"

if (methodsflag==3)
methodstr<-"sfn"


if (methodstr=="br") {

if (Ncols==3)
Fit.i<-rq(Yield~var1,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==4)
Fit.i<-rq(Yield~var1+var2,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==5)
Fit.i<-rq(Yield~var1+var2+var3,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==6)
Fit.i<-rq(Yield~var1+var2+var3+var4,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==7)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==8)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==9)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==10)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==11)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==12)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==13)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==14)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==15)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==16)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==17)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==18)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==19)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==20)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==21)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==22)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==23)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20+var21,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)
if (Ncols==24)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20+var21+var22,tau=tt,weight=W,ci=TRUE,alpha=aa,method=methodstr)

} else {
if (Ncols==3)
Fit.i<-rq(Yield~var1,tau=tt,weight=W,method=methodstr)
if (Ncols==4)
Fit.i<-rq(Yield~var1+var2,tau=tt,weight=W,method=methodstr)
if (Ncols==5)
Fit.i<-rq(Yield~var1+var2+var3,tau=tt,weight=W,method=methodstr)
if (Ncols==6)
Fit.i<-rq(Yield~var1+var2+var3+var4,tau=tt,weight=W,method=methodstr)
if (Ncols==7)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5,tau=tt,weight=W,method=methodstr)
if (Ncols==8)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6,tau=tt,weight=W,method=methodstr)
if (Ncols==9)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7,tau=tt,weight=W,method=methodstr)
if (Ncols==10)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8,tau=tt,weight=W,method=methodstr)
if (Ncols==11)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9,tau=tt,weight=W,method=methodstr)
if (Ncols==12)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10,tau=tt,weight=W,method=methodstr)
if (Ncols==13)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11,tau=tt,weight=W,method=methodstr)
if (Ncols==14)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12,tau=tt,weight=W,method=methodstr)
if (Ncols==15)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13,tau=tt,weight=W,method=methodstr)
if (Ncols==16)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14,tau=tt,weight=W,method=methodstr)
if (Ncols==17)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15,tau=tt,weight=W,method=methodstr)
if (Ncols==18)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16,tau=tt,weight=W,method=methodstr)
if (Ncols==19)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17,tau=tt,weight=W,method=methodstr)
if (Ncols==20)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18,tau=tt,weight=W,method=methodstr)
if (Ncols==21)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19,tau=tt,weight=W,method=methodstr)
if (Ncols==22)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20,tau=tt,weight=W,method=methodstr)
if (Ncols==23)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20+var21,tau=tt,weight=W,method=methodstr)
if (Ncols==24)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10+var11+var12+var13+var14+var15+var16+var17+var18+var19+var20+var21+var22,tau=tt,weight=W,method=methodstr)

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





