function O=IonEOverlay(newdata,where,recipient)
%IONEOVERLAY - put newdata onto recipient as directed by where, a logical
%matrix or linear indices.
recipient(where)=newdata(where);
O=recipient;