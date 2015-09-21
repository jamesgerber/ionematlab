
WetFlag='TMI';
HeatFlag='GDD';
Rev='F';
CropNo=7;
N=10;
YieldGapFunction

load ../TMI



figure
zeroxlim(0,12000);
zeroylim(0,5);
ht=[];
[Xval,Yval]=ClimateSpaceCoords(44.93, -93.05,GDD,TMI);
Xval=double(Xval);Yval=double(Yval);
ht(end+1)=text(Xval,Yval,['o' 'Saint Paul']);

[Xval,Yval]=ClimateSpaceCoords(43.13, -89.33,GDD,TMI);
Xval=double(Xval);Yval=double(Yval);
ht(end+1)=text(Xval,Yval,['o' 'Madison']);

[Xval,Yval]=ClimateSpaceCoords(47.45, -122.30,GDD,TMI);
Xval=double(Xval);Yval=double(Yval);
ht(end+1)=text(Xval,Yval,['o' 'Seattle']);

[Xval,Yval]=ClimateSpaceCoords(50.25, 30.43,GDD,TMI);
Xval=double(Xval);Yval=double(Yval);
ht(end+1)=text(Xval,Yval,['o' 'Kiev Borispol, Ukraine']);

%KBP KIEV BORISPOL, UKRAINE	50 25 N		30 43 E


%[ICT]  37.65   97.43  Wichita,KS
%[DBQ]  42.40   90.70  Dubuque,IA
%[MSN]  43.13   89.33  Madison,WI
%[SEA]  47.45  122.30  Seattle,WA
%DEL DELHI, INDIA		28 40 N		77 14 E
%TAS TASHKENT, UZBEKISTAN	41 16 N		69 13 E

%RUH RIYADH, SAUDI ARABIA	24 39 N		46 46 E
%ALG ALGIERS, ALGERIA		36 50 N		3 00 E
%BOD BORDEAUX, FRANCE		44 50 N		0 34 W
%REK REYKJAVIK, ICELAND		64 09 N		21 51 W
%MAD MADRID, SPAIN		40 24 N		3 41 W
%BSB BRASILIA, BRAZIL		15 47 S		47 55 W
%ANF ANTOFAGASTA, CHILE		23 40 S		70 23 W
%REC RECIFE, BRAZIL		8 06 S		34 53 W
%PEK BEIJING, CHINA		39 55 N		116 26 E
%BOM BOMBAY, INDIA		18 56 N		74 35 W
%CCU CALCUTTA, INDIA		22 30 N		88 20 E
%DEL DELHI, INDIA		28 40 N		77 14 E
%HAN HANOI, VIETNAM		21 01 N		105 52 E
%HRB HARBIN, CHINA		45 45 N		126 41 E