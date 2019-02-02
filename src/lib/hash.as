#module
#uselib "advapi32.dll"
#cfunc CryptAcquireContext "CryptAcquireContextA" sptr,sptr,sptr,sptr,sptr
#cfunc CryptCreateHash "CryptCreateHash" sptr,sptr,sptr,sptr,sptr
#cfunc CryptHashData "CryptHashData" sptr,sptr,sptr,sptr
#cfunc CryptGetHashParam "CryptGetHashParam" sptr,sptr,sptr,sptr,sptr
#func CryptDestroyHash "CryptDestroyHash" sptr
#func CryptReleaseContext "CryptReleaseContext" sptr,sptr
#define HP_HASHVAL	$00000002
#define PROV_RSA_FULL	$00000001
#define CRYPT_VERIFYCONTEXT	$F0000000
#define CRYPT_MACHINE_KEYSET	$00000020
#define global ctype GetHash_MD2(%1, %2) GetHash(%1, %2, $00008001)		//MD2ハッシュアルゴリズム
#define global ctype GetHash_MD4(%1, %2) GetHash(%1, %2, $00008002)		//MD4ハッシュアルゴリズム
#define global ctype GetHash_MD5(%1, %2) GetHash(%1, %2, $00008003)		//MD5ハッシュアルゴリズム
#define global ctype GetHash_SHA1(%1, %2) GetHash(%1, %2, $00008004)	//SHA-1ハッシュアルゴリズム
#defcfunc GetHash var _pData, int _dwLen, int _Algid, local l1, local l2, local l3, local Algid, local hProv, local hHash, local pbHash, local dwHashLen
if CryptAcquireContext(varptr(hProv), 0, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT | CRYPT_MACHINE_KEYSET) {
	if CryptCreateHash(hProv, _Algid, 0, 0, varptr(hHash)) {
		if CryptHashData(hHash, varptr(_pData), _dwLen, 0) {
			if CryptGetHashParam(hHash, HP_HASHVAL, 0, varptr(dwHashLen), 0) {
				dim pbHash, dwHashLen/4
				if CryptGetHashParam(hHash, HP_HASHVAL, varptr(pbHash), varptr(dwHashLen), 0) {
					l3 = ""
					foreach pbHash
						l1 = strf("%08X", pbHash(cnt))
						l2 = ""
						repeat strlen(l1)/2
							 l2 = strmid(l1, cnt*2, 2) + l2
						loop
						l3 += l2
					loop
					CryptDestroyHash Hhash
					CryptDestroyHash hProv
					return l3

				}
			}
		}
	}
}
CryptDestroyHash Hhash
CryptDestroyHash hProv
return 0

#global
