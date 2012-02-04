plot(100*TO.goodquantitysorted/max(TO.goodquantitysorted),100*TO.badquantitysorted/max(TO.badquantitysorted),100*[0 1],100*[0 1])
xlabel(' good thing - % ')
ylabel(' bad thing - %')
grid on

title([' Bad thing used to produce a good thing '])
zeroxlim(0,100)
zeroylim(0,100)