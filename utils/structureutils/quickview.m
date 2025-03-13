function quickview(sov);
% quickview - put up an excel of a structure of vectors


sov2csv(sov,'tmpforquickview.csv');
excel tmpforquickview.csv

