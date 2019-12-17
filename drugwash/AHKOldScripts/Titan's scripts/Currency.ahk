/*
	Title: Currency Converter
	
	Function: Currency
	
	A basic currency converter that uses the latest rates
	from Yahoo! Finance <http://finance.yahoo.com/currency>.
	
	Parameters:
		c1 - currency code to change from
		c2 - currency code to change to
	
	Returns:
		Exchange rate.
	
	About: Example
		- Currency("GBP", "USD") * 5: returns the value in USD of £5 GBP
	
	About: License
		- Version 1.1 by Titan <http://www.autohotkey.net/~Titan/#currency>.
		- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.

*/

Currency(c1, c2) {
	t = %A_Temp%\cc-%A_Now%.tmp
	URLDownloadToFile
		, *0 http://finance.yahoo.com/d/quotes.csv?s=%c1%%c2%=X&f=l1&e=.csv, %t%
	FileRead, v, %t%
	FileDelete, %t%
	Return, SubStr(v, 1, -2)
}
