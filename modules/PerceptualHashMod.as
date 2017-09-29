#module

#defcfunc PopCnt int _bit

	num = _bit

	num = (num & 0x55555555) + (num >> 1 & 0x55555555)
    num = (num & 0x33333333) + (num >> 2 & 0x33333333)
    num = (num & 0x0f0f0f0f) + (num >> 4 & 0x0f0f0f0f)
    num = (num & 0x00ff00ff) + (num >> 8 & 0x00ff00ff)
    
return (num & 0x0000ffff) + (num >>16 & 0x0000ffff)

#define global ctype HammingDist( %1, %2) PopCnt(%1(0) xor %2(0)) + PopCnt(%1(1) xor %2(1))


#deffunc CmptDHash array hash, array vram

	dim hash, 2

	pLum = (( (vram(0)&0xFF)*18 + ((vram(0)>>8)&0xFF)*158 + ((vram(0)>>16)&0xFF)*80 ) >> 8) & 0xFF

	repeat 64
		lum = (( (vram(cnt+1)&0xFF)*18 + ((vram(cnt+1)>>8)&0xFF)*158 + ((vram(cnt+1)>>16)&0xFF)*80 ) >> 8) & 0xFF
		hash(cnt/32) <<= 1
		hash(cnt/32) |= (pLum > lum)
		pLum = lum
	loop

return

#deffunc CmptAHash array hash, array vram

	dim hash, 2
	dim tCol, 64
	avgCol = 0

	repeat 64
		tCol(cnt) = (( (vram(cnt+1)&0xFF)*18 + ((vram(cnt+1)>>8)&0xFF)*158 + ((vram(cnt+1)>>16)&0xFF)*80 ) >> 8) & 0xFF
		avgCol += tCol(cnt)
	loop

	avgCol /= 64
	
	repeat 64
		hash(cnt/32) <<= 1
		hash(cnt/32) |= (tCol(cnt) > avgCol)
	loop

	dim tCol, 0
return



#global