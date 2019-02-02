#module "DeleteFolderMod"
#uselib "shell32"
#func SHFileOperation "SHFileOperationW" int
#define FO_DELETE 0x0003
#define FOF_NOCONFIRMATION 0x010
#define FOF_SIMPLEPROGRESS 0x100

#deffunc deleteFolder str dir_
	sdim dDir, 1024
    cnvstow dDir, dir_

	dim SHFILEOP_STRUCT, 8
	SHFILEOP_STRUCT(0) = hWnd
	SHFILEOP_STRUCT(1) = FO_DELETE
	SHFILEOP_STRUCT(2) = varptr(dDir)
	SHFILEOP_STRUCT(4) = FOF_SIMPLEPROGRESS|FOF_NOCONFIRMATION

	SHFileOperation varptr(SHFILEOP_STRUCT)
return stat
#global
