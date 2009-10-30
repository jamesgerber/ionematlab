function assignvalue(name,value)
%embarassing piece of code to avoid 'eval' statements.
assignin('caller',name,value)
