#ifndef GDB_SERVER_H
#define GDB_SERVER_H
#include<WinSock2.h>
#include<windows.h>
#define recv_len (4096u)
extern char *recvbuf;
extern SOCKET this_con;
extern int RingBufRead(char*pbuf,int len);
extern unsigned int recv_index;
void gdb_server_init(HANDLE hComm);
unsigned int process_packet();
unsigned int CheckSum(unsigned char *buf,unsigned int len);
#endif