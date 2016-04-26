
# Jamie code to carry out quantile regression using quantreg package in R. 
# this reads in datafile.csv, which must evaulate to an array whose first column is Yield and whose second column is weights.  The next N columns are sent in as variables to the QR analysis.

# first read in datafile.csv file with y,x1,x2,x3 ... etc.

#setwd("/Users/jsgerber/sandbox/jsg114_yieldgapswithQR")

#############
####Data#####
#############
library(R.matlab)
newdata<-readMat("transferdatatoR.mat")
data2<-newdata$BigArray

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
                   

####Tested quantiles####
library("quantreg")

if (Ncols==4)
Fit.i<-rq(Yield~var1+var2,tau=.95,weight=W)
if (Ncols==5)
Fit.i<-rq(Yield~var1+var2+var3,tau=.95,weight=W)
if (Ncols==6)
Fit.i<-rq(Yield~var1+var2+var3+var4,tau=.95,weight=W)
if (Ncols==7)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5,tau=.95,weight=W)
if (Ncols==8)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6,tau=.95,weight=W)
if (Ncols==9)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7,tau=.95,weight=W)
if (Ncols==10)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8,tau=.95,weight=W)
if (Ncols==11)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9,tau=.95,weight=W)
if (Ncols==12)
Fit.i<-rq(Yield~var1+var2+var3+var4+var5+var6+var7+var8+var9+var10,tau=.95,weight=W)

	Theta<-coef(Fit.i)
	print(Theta)
	write(Theta,file='output.txt',ncolumns=1)
