//
//  UploadSoft.c
//  UploadSoft
//
//  Created by shulianyong on 13-11-30.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include "UploadSoft.h"

#define BUFFER_SIZE 				1024
#define BS_UPG_PORT					8000

#define FILE_NAME_MAX_SIZE            512
#define DATA_END_MARK				0x89ABCDEF
#define HEADER_MARK					0xFEFEFEFE

typedef struct _st_transfer_cmd_
{
	int mark;
	CMD_TRANSFER_CONTENT cmd;
	unsigned int crc32;
	unsigned int len;
	int addition_val;
}ST_TRANSFER_CMD;


unsigned int get_checksum(unsigned char *buffer, int len)
{
	int index;
	unsigned int checksum = 0;
    
	for (index = 0; index < len; index++)
	{
		checksum += buffer[index];
	}
    
	return checksum;
}

void DumpData(unsigned char *buffer, int length)
{
	int index;
    
	for (index = 0; index < length; index++)
	{
		printf("%02x ", buffer[index]);
		if ((index + 1) % 16 == 0)
		{
			printf("\n");
		}
	}
	printf("\n");
}

//发送文件到STB
void send_file_to_stb(CMD_TRANSFER_CONTENT _transType,int client_socket,const char *file_name)
{
	printf("transfer file %s\n", file_name);
    
	unsigned char buffer[BUFFER_SIZE];
	FILE *fp = fopen(file_name, "r");
	if (fp == NULL)
	{
		printf("File:\t%s Not Found!\n", file_name);
	}
	else
	{
		//get checksum for the file
		bzero(buffer, BUFFER_SIZE);
		int file_block_length = 0;
		unsigned int file_length = 0;
		unsigned int checksum = 0;
		while( (file_block_length = fread(buffer, sizeof(char), BUFFER_SIZE, fp)) > 0)
		{
            //			printf("file_block_length = %d\n", file_block_length);
            
			checksum += get_checksum(buffer, file_block_length);
			file_length += file_block_length;
			bzero(buffer, sizeof(buffer));
		}
		//send header for transfer
		bzero(buffer, sizeof(buffer));
		ST_TRANSFER_CMD transfer_cmd;
		transfer_cmd.mark = HEADER_MARK;
		transfer_cmd.cmd = _transType;
		transfer_cmd.crc32 = checksum;
		transfer_cmd.len = file_length;
		memcpy(buffer, &transfer_cmd, BUFFER_SIZE);
		send(client_socket, buffer, BUFFER_SIZE, 0);
		printf("check sum 0x%x\n", checksum);
        //		DumpData(buffer, BUFFER_SIZE);
		fseek(fp, 0, SEEK_SET);
        
		//send all file by cycle
		bzero(buffer, BUFFER_SIZE);
		while( (file_block_length = fread(buffer, sizeof(char), BUFFER_SIZE, fp)) > 0)
		{
            //			printf("file_block_length = %d\n", file_block_length);
            
			if (send(client_socket, buffer, file_block_length, 0) < 0)
			{
				printf("Send File:\t%s Failed!\n", file_name);
				break;
			}
            
			bzero(buffer, sizeof(buffer));
		}
		fclose(fp);
		printf("File:\t%s Transfer Finished!\n", file_name);
	}
	//end
}

static int excute_ret_messge(CMD_TRANSFER_CONTENT _transType,int sockfd, int ret, int value,const char *file_name,uploadFileResult resultCallback,uploadProgress progressCallback)
{
	int close_fd = 0;
	if (ret == CMD_RET_TRANSFER_OK)
	{
		printf("get response send file CMD_RET_TRANSFER_OK\n");
        resultCallback(CMD_RET_TRANSFER_OK);
		close_fd = 0;
	}
	else if(ret == CMD_RET_TRANSFER_CRC32_ERR)
	{
		printf("get response send file CMD_RET_TRANSFER_CRC32_ERR,transfer crc check fail\n");
        resultCallback(CMD_RET_TRANSFER_CRC32_ERR);
		close_fd  = 1;
	}
	else if(ret == CMD_RET_UPGRADE_CRC_CHECK_FAIL)
	{
		printf("get response send file CMD_RET_TRANSFER_CRC32_ERR,invalid upgrade file,please check source file\n");
        resultCallback(CMD_RET_UPGRADE_CRC_CHECK_FAIL);
		close_fd  = 1;
	}
	else if(ret == CMD_RET_SERVER_CONNECT_BUSY)
	{
		printf("get response send file CMD_RET_SERVER_BUSY\n");
        resultCallback(CMD_RET_SERVER_CONNECT_BUSY);
		close_fd  = 1;
	}
	else if(ret == CMD_RET_SERVER_CONNECT_SAFE)
	{
		printf("get response send file CMD_RET_SERVER_CONNECT_SAFE\n");
		send_file_to_stb(_transType,sockfd,file_name);
		close_fd  = 0;
        
	}
	else if (CMD_RET_UPGRADE_PROCESS == ret)
	{
		//for display process for update
		printf("upgrade process ->%d\n", value);
        progressCallback(value);
		close_fd = 0;
	}
	else if (CMD_RET_UPDATE_FAIL == ret)
	{
		printf("some err happen when upgrade stb\n");
        resultCallback(CMD_RET_UPDATE_FAIL);
		close_fd = 1;
	}
	else if (CMD_RET_UPDATE_SUCCESS == ret)
	{
		printf("UPDATE STB SUCCESS\n");
        resultCallback(CMD_RET_UPDATE_SUCCESS);
		close_fd = 1;
	}
    
	return close_fd;
}

void sendSTBFile(CMD_TRANSFER_CONTENT _transType,const char* aFile,const char *aIP,uploadFileResult resultCallback,uploadProgress progressCallback)
{
//    str =
    
//    stpncpy(str, aFile, 1024);
    
	int sockfd, len;
	struct sockaddr_in dest;
	char buf[BUFFER_SIZE + 1];
	fd_set rfds;
	struct timeval tv;
	int retval, maxfd = -1;
    
	int port = BS_UPG_PORT;
    
    
    printf("%s %d Usage: %d IP Port",__FILE__,__LINE__,port);
    
    
    
	if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
	{
		perror("Socket");
        printf("%s %d Usage: socket创建失败",__FILE__,__LINE__);
        resultCallback(CMD_RET_UPDATE_FAIL);
	}
    
	bzero(&dest, sizeof(dest));
	dest.sin_family = AF_INET;
	dest.sin_port = htons(port);
    
    
	if (inet_aton(aIP, (struct in_addr *)&dest.sin_addr.s_addr) == 0)
	{
		perror(aIP);
        resultCallback(CMD_RET_UPDATE_FAIL);
        
	}
    
	if (connect(sockfd, (struct sockaddr *)&dest, sizeof(dest)) != 0)
	{
		perror("Connect ");
        resultCallback(CMD_RET_UPDATE_FAIL);
	}
    
	printf("connect to server...\n");
    
	while (1)
	{
        
		FD_ZERO(&rfds);
        //		FD_SET(0, &rfds);
		maxfd = 0;
        
		FD_SET(sockfd, &rfds);
		if (sockfd > maxfd)
			maxfd = sockfd;
        
		tv.tv_sec = 1;
		tv.tv_usec = 0;
        
		retval = select(maxfd + 1, &rfds, NULL, NULL, &tv);
        
		if (retval == -1)
		{
            resultCallback(CMD_RET_UPDATE_FAIL);
			printf("select error! %s", strerror(errno));
			break;
		}
		else if (retval == 0)
		{
			//printf("no msg,no key, and continue to wait鈥︹€n");
            //			printf("..........%s,%d\n", __FUNCTION__, __LINE__);
			continue;
		}
		else
		{
			if (FD_ISSET(0, &rfds))
			{
				printf("..........%s,%d\n", __FUNCTION__, __LINE__);
			}
			else if (FD_ISSET(sockfd, &rfds))
			{
				//get all return value
				bzero(buf, BUFFER_SIZE + 1);
				len = recv(sockfd, buf, BUFFER_SIZE, 0);
				if (len > 0)
				{
					ST_TRANSFER_CMD st_ret_cmd;
					memcpy(&st_ret_cmd, buf, sizeof(ST_TRANSFER_CMD));
					if (excute_ret_messge(_transType,sockfd, st_ret_cmd.cmd, st_ret_cmd.addition_val,aFile,resultCallback,progressCallback))
					{
						break;
					}
				}
				else
				{
                    resultCallback(CMD_RET_UPDATE_FAIL);
					if (len < 0)
						printf("recv failed errno:%d eror msg: '%s'\n", errno, strerror(errno));
					else
						printf("other exit Terminal chat\n");
					break;
				}
			}
		}
	}    
	close(sockfd);
}
