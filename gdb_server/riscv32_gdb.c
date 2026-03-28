#include<stdio.h>
#include <conio.h>
#include <sys/stat.h>
#include<stdlib.h>
#include<WinSock2.h>
#include<windows.h>
#include<stdio.h>
#include"gdb_server.h"
#include"riscv_cpu_handle.h"
#include <process.h>   // _beginthreadex
#pragma comment(lib,"winmm.lib")
#pragma comment(lib,"user32.lib")
#pragma comment(lib,"gdi32.lib")
#pragma comment(lib,"ws2_32.lib")

#pragma pack (4)
#pragma pack ()
typedef struct ParameterData
{
    char*COM;
    DWORD BaudRate;
    unsigned short GDB_PORT;
    unsigned int init_halt_flag;
    unsigned int init_reset_flag;
}ParameterData;
SOCKET this_con;
unsigned int ack_flag=1;
int packet_write(char *buf)
{
	unsigned int len = strlen(buf);
	char *sendbuf;
	send(this_con,"+",1,0);
    if(len>0)
    {
        sendbuf = (char*)malloc(len+12);
        memset(sendbuf,0,len+12);
    }
    else
    {
	    sendbuf = (char*)malloc(4096);
        memset(sendbuf,0,4096);
    }
    
	if(len == 0)
	{
		sprintf(sendbuf,"$#00");
	}
	else
	{
		sprintf(sendbuf,"$%s#%02X",buf,CheckSum((unsigned char*)buf,len));
	}
    send(this_con,sendbuf,len+4,0);
	free(sendbuf);
    return 1;
}

void display_buf(unsigned char buf[],unsigned int len)
{
    unsigned int i,temp;
    for(i=0;i<len;i+=4)
    {
        printf("0x%04x:",i);
        temp = (buf[i+3] << 24)|(buf[i+2] << 16)|(buf[i+1] << 8)|buf[i+0];
        printf("0x%08x\r\n",temp);
    }
}
void display_hex(unsigned char buf[],unsigned int len)
{
    unsigned int i;
    puts("cmd hex:");
    for(i=0;i<len;i++)
    {
        printf("0x02x ",buf[i]);
    }
    puts("");
}
#define RingBufLen 8192
static int write_point=0;
static int read_point  = 0;
static unsigned char ringbuf[RingBufLen];
int GetBufLen()
{
    if(write_point != read_point)
    {
        if(read_point<write_point)
        {
            return (write_point - read_point);
        }
        else
        {
            return (RingBufLen - read_point) + write_point;
        }
    }
    return 0;
}
int RingBufRead(char*pbuf,int len)
{
    if(write_point != read_point)
    {
        int reallen,ret,i;
        ret = GetBufLen();
        reallen = len;
        if(ret < len)
        {
            reallen = ret;
        }
        int value;
        value = RingBufLen - read_point;
        if(value>reallen)
        {
            memcpy(pbuf,ringbuf+read_point,reallen);
        }
        else
        {
            memcpy(pbuf,ringbuf+read_point,value);
            memcpy(pbuf+value,ringbuf,reallen-value);
        }
        read_point = (read_point+reallen)%RingBufLen;
        return reallen;
    }
    return 0;
}
unsigned int __stdcall ClientThread(void* data) {
    int i=0;
    while(1)
    {
        memset(recvbuf,0,recv_len);
        recv_index = RingBufRead(recvbuf,1024);
        while(strstr(recvbuf,"#") == NULL)
        {
            i = RingBufRead(recvbuf+recv_index,1024);
            recv_index += i;
        }
        recv_index = 0;
        if(0 != process_packet())
        {
            puts("next connect");
            continue;
        }
    }
    return 0;
}
void RingBufPut(char*buf,int len)
{

    int value;
    value = (RingBufLen - write_point);
    if((RingBufLen - write_point) < len)
    {
        memcpy(ringbuf+write_point,buf,value);
        memcpy(ringbuf,buf+value,len-value);
    }
    else
    {
            memcpy(ringbuf+write_point,buf,len);
    }
    write_point = ((write_point+len)%RingBufLen);
}
void gdb_server(ParameterData *parameterData,HANDLE hComm)
{
	SOCKET sockServer,con;
	SOCKADDR_IN client,addrServer;
	int size;
	unsigned int i;
    char ch;
    WORD wVerisonRequested;
	WSADATA wsaData;
	int err;
	wVerisonRequested = MAKEWORD(1, 1);
	err = WSAStartup(wVerisonRequested, &wsaData);
	if (err != 0)
	{
		printf("error");
		system("pause");
		return ;
	}
	sockServer= socket(AF_INET, SOCK_STREAM, 0);
	// bind socket
	addrServer.sin_addr.S_un.S_addr = htonl(INADDR_ANY);
	addrServer.sin_family = AF_INET;
	addrServer.sin_port = htons(parameterData->GDB_PORT);
	if(-1 == bind(sockServer, (SOCKADDR *)&addrServer, sizeof(addrServer)))
    {
        puts("bund failed");
    }
	//listen socket
	listen(sockServer,5);
	size=sizeof(client);
	gdb_server_init(hComm);
    
    HANDLE hThread = (HANDLE)_beginthreadex(NULL, 0, ClientThread,
                                                    NULL, 0, NULL);
            if (hThread)
                CloseHandle(hThread);        // 只需关闭句柄，线程继续运行


	while(1)
	{
        char pbuf[1024];
        int ret;
		con=accept(sockServer,(SOCKADDR *)&client,&size);
        if(con == NULL)
        {
            printf("socket error\r\n");
        }
        this_con = con;
        while(1)
        {
			memset(pbuf,0,1024);

            ret = recv(con,pbuf,1024,0);
			if(ret>0)
            {
                RingBufPut(pbuf,ret);
            }
            else if(ret==0)
            {
                break;
            }
			
            
        }
        closesocket(con);
	}
}

void ParameterInit(ParameterData *parameterData,unsigned int argc,char*argv[])
{
    unsigned int i;
    char *s_temp;
    for(i = 0; i < argc; i++)
    {
        if(NULL != (s_temp = strstr(argv[i],"-com")))
        {
            parameterData->COM = s_temp + strlen("-com");
        }
        else if(NULL != (s_temp = strstr(argv[i],"-baudrate")))
        {
            sscanf(s_temp + strlen("-baudrate"),"%d",&(parameterData->BaudRate));
        }
        else if(NULL != (s_temp = strstr(argv[i],"-port")))
        {
            sscanf(s_temp + strlen("-port"),"%d",&(parameterData->GDB_PORT));
        }
        else if(NULL != (s_temp = strstr(argv[i],"reset")))
        {
            parameterData->init_reset_flag = 1;
        }
        else if(NULL != (s_temp = strstr(argv[i],"halt")))
        {
            parameterData->init_halt_flag = 1;
        }
    }
}
void debug_reset(HANDLE hComm)
{
    unsigned int i;
    for(i = 0; i < 10;i++)
    {
        if(0 != DebugReset(hComm))
        {
            break;
        }
    }
    if(i < 10)
    {
        puts("debug reset faild");
    }
}
void Riscv32Init(HANDLE hComm,ParameterData *parameterData)
{
    debug_reset(hComm);
    PurgeComm(hComm,PURGE_TXCLEAR|PURGE_RXCLEAR);
    if(parameterData->init_halt_flag)
    {
        if(0 == HaltCPU(hComm))
        {
            puts("cpu halted");
        }
    }
    if(parameterData->init_reset_flag)
    {
        if(0 == ResetCPU(hComm))
        {
            puts("cpu was reset");
        }
    }
}
void main(unsigned int argc,char*argv[])
{
    int rtn;
    unsigned int mem_type;
    unsigned char buf[16];
    size_t fileRDsize;
    ParameterData parameterData;
    unsigned int i;
    unsigned int inscode;
    unsigned int wdata;
    unsigned int rdata;
    unsigned short addr;
    unsigned char wb;
    DWORD wCount;
    unsigned int pcount;
    HANDLE hComm;
    long int filelen;
    FILE *f,*f2;
	BOOL bReadStat;
    COMMTIMEOUTS TimeOuts;
	DCB usart1;
    /**
     * @brief鍒濆鍙傛暟鍒濆锟??
     * 
     */
    parameterData.COM = NULL;
    parameterData.GDB_PORT = 8080;
    parameterData.BaudRate = 115200;
    parameterData.init_halt_flag = 0;
    parameterData.init_reset_flag = 0;
    {
        char buf[10];
        sprintf(buf,"\x74%08x",0x12345678);
        puts(buf);
    }
    ParameterInit(&parameterData,argc,argv);
    if(NULL == parameterData.COM)
    {
        puts("please input Serial Name");
        return;
    }
    sprintf((char*)buf,"\\\\.\\%s",parameterData.COM);
    hComm = CreateFile((char*)buf,GENERIC_READ|GENERIC_WRITE,
	0, NULL, OPEN_EXISTING, 0, 0);
    if(hComm==(HANDLE)-1)
	{
		printf("serial %s open fail\r\n",argv[1]);
		return ;
	}
    SetupComm(hComm,1024,1024);
	TimeOuts.ReadIntervalTimeout=500;
	TimeOuts.ReadTotalTimeoutMultiplier=500;
	TimeOuts.ReadTotalTimeoutConstant=500;//璁惧畾鍐欒秴锟??
	TimeOuts.WriteTotalTimeoutMultiplier=0;
	TimeOuts.WriteTotalTimeoutConstant=500;
	SetCommTimeouts(hComm,&TimeOuts);
	GetCommState(hComm,&usart1);
	usart1.BaudRate=parameterData.BaudRate;
	usart1.StopBits=ONESTOPBIT;
	usart1.Parity=NOPARITY;
	usart1.ByteSize=8;
	SetCommState(hComm,&usart1);	
	PurgeComm(hComm,PURGE_TXCLEAR|PURGE_RXCLEAR);
    puts("");
    Riscv32Init(hComm,&parameterData);
	PurgeComm(hComm,PURGE_TXCLEAR|PURGE_RXCLEAR);
    for(int i=0; i < 2; i++)
    {
        CPU_HardBreakPointWrite(hComm,i,0);
    }
    gdb_server(&parameterData,hComm);
    //usart_send(hComm,buf,4,&wCount);//鍙戦�乯alr x0,0(x0)鎸囦护浣緾PU澶嶄綅
    // Sleep(1000);
    //usart_send(hComm,buf,4,&wCount);
    CPU_GeneralRegisterWrite(hComm,0x20,0);
    
    ResumeCPU(hComm);
}
