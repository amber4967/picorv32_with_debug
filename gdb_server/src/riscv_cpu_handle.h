#ifndef RISCV_CPU_HANDLE_H
#define RISCV_CPU_HANDLE_H
#include<stdio.h>
#include <conio.h>
#include <sys/stat.h>
#include<stdlib.h>
#include<windows.h>

#ifdef GDB_DBG
#define GDB_printf(...) printf(__VA_ARGS__)
#else
#define GDB_printf(...)
#endif

int usart_send(HANDLE COM,void*pbuf,unsigned int len,DWORD *iLen);
int usart_recv(HANDLE COM,unsigned char *pbuf,unsigned int len);
int DebugReset(HANDLE hComm);
int HaltCPU(HANDLE hComm);
int ResetCPU(HANDLE hComm);
int CPUisHalted(HANDLE hComm);
int ResumeCPU(HANDLE hComm);
int StepiCPU(HANDLE hComm);
int CPUmemoryWriteWord(HANDLE hComm,unsigned int addr,unsigned int wdata);
int CPUmemoryWriteHalfWord(HANDLE hComm,unsigned int addr,unsigned short wdata);
int CPUmemoryWriteByte(HANDLE hComm,unsigned int addr,unsigned char wdata);
int CPUmemoryReadWord(HANDLE hComm,unsigned int addr,unsigned int *rdata);
int CPUmemoryReadHalfWord(HANDLE hComm,unsigned int addr,unsigned short *rdata);
int CPUmemoryReadByte(HANDLE hComm,unsigned int addr,unsigned char *rdata);
int CPU_GeneralRegisterWrite(HANDLE hComm,unsigned int index,unsigned int wdata);
int CPU_GeneralRegisterRead(HANDLE hComm,unsigned int index,unsigned int *rdata);
int CPU_HardBreakPointAdd(HANDLE hComm,unsigned int addr);
int CPU_HardBreakPointDel(HANDLE hComm,unsigned int addr);
int CPU_HardBreakPointWrite(HANDLE hComm,unsigned int index,unsigned int wdata);
int DebugMemCtlWrite(HANDLE hComm,unsigned int value);
int DebugMemAddrWrite(HANDLE hComm,unsigned int addr);
int DebugMemDataWrite(HANDLE hComm,unsigned int value,unsigned char wstr);
int DebugMemDataRead(HANDLE hComm,unsigned int *value);
#endif
