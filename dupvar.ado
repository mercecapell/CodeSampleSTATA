prog def dupvar
	
	#delim ;
	syntax varlist;
	#delim cr

	sort `varlist'
	quietly by `varlist' :  gen dupvar = cond(_N==1,0,_n)
end
