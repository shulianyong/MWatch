//
//  UploadUtil.c
//  STB
//
//  Created by shulianyong on 13-11-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//



#define BUFFER_SIZE 				1024
#define BS_UPG_PORT					8000
#define FILE_NAME_MAX_SIZE            512
#define DATA_END_MARK				0x89ABCDEF
#define HEADER_MARK					0xFEFEFEFE
#define SEND_FILE_NAME				"flashrom.bin"
typedef enum
{
	CMD_TRANSFER_STB_FIRMWARE = 0x10,
	CMD_TRANSFER_STB_DATABASE,
	CMD_TRANSFER_STB_LOGO,
}CMD_TRANSFER_CONTENT;

typedef enum
{
	CMD_RET_SERVER_CONNECT_BUSY= 0x20,
	CMD_RET_SERVER_CONNECT_SAFE,
	CMD_RET_TRANSFER_OK,
	CMD_RET_TRANSFER_CRC32_ERR,
	CMD_RET_UPGRADE_CRC_CHECK_FAIL,
	CMD_RET_UPGRADE_PROCESS,
	CMD_RET_UPDATE_FAIL,
	CMD_RET_UPDATE_SUCCESS
}CMD_RET_CONTEN;

typedef struct _st_transfer_cmd_
{
	int mark;
	CMD_TRANSFER_CONTENT cmd;
	unsigned int crc32;
	unsigned int len;
	int addition_val;
}ST_TRANSFER_CMD;


