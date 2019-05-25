#module Math

//max,minともに整数のみ対応
//小数点数を渡すと切り捨てられる
#define ctype max(%1=2147483647,%2=0) _max@Math(%1, %2)
#defcfunc local _max int p1, int p2
    if p1>p2:return p1
return p2

#define ctype min(%1=-2147483648,%2=0) _min@Math(%1, %2)
#defcfunc local _min int p1, int p2
    if p1<p2:return p1
return p2

#global

#if 0
	mes max@Math(-1,1)
	mes min@Math(-1,1)
    mes max@Math(-1)
	mes min@Math(-1)
    mes max@Math(1)
	mes min@Math(1)
    mes max@Math()
	mes min@Math()
#endif
