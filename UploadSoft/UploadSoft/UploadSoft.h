//
//  UploadSoft.h
//  UploadSoft
//
//  Created by shulianyong on 13-11-30.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

typedef enum UploadResultStatus
{
	CMD_RET_SERVER_CONNECT_BUSY= 0x20,
	CMD_RET_SERVER_CONNECT_SAFE,
	CMD_RET_TRANSFER_OK,
	CMD_RET_TRANSFER_CRC32_ERR,
	CMD_RET_UPGRADE_CRC_CHECK_FAIL,
	CMD_RET_UPGRADE_PROCESS,
	CMD_RET_UPDATE_FAIL,
	CMD_RET_UPDATE_SUCCESS
}_UploadResultStatus;

typedef enum _CMD_TRANSFER_CONTENT
{
	STB_SECTION_ALL = 0x10,
	STB_SECTION_USER,
	STB_SECTION_DB
}CMD_TRANSFER_CONTENT;


typedef void(^uploadProgress)(int aProcessValue);
typedef void (^uploadFileResult)(_UploadResultStatus aStatus);

void sendSTBFile(CMD_TRANSFER_CONTENT _transType,const char* aFile,const char *aIP,uploadFileResult resultCallback,uploadProgress progressCallback);

