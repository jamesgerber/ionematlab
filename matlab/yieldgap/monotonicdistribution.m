function jpmax=monotonicdistribution(jp)
% MONOTONICDISTRIBUTION - add to a distribution so all contours
% concentric
%
%  This works by finding the maximum of the distribution, and then
%  for every point Pj a rectangle is defined by opposing corners
%  being the maximum point and Pj. Then, any points within
%  rectangle which are less than the value of Pj are replaced with
%  Pj.  This is repeated for all points Pj.


[dum,Mr,Mc]=max2d(jp);
[Nr Nc]=size(jp)

jpmax=jp;


for r=1:Nr;
  if r>Mr
    rr=(Mr:r);
  else
    rr=(Mr:-1:r);
  end
    for c=1:Nc;
      if c>Mc
	cc=Mc:c;
      else
	cc=Mc:-1:c;
      end
      
      
      jpmax(rr,cc)=max(jpmax(rr,cc),jp(r,c));
      
    end
end

    