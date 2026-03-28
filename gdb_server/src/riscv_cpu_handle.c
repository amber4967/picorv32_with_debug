#include"riscv_cpu_handle.h"
int usart_send(HANDLE COM,void*pbuf,unsigned int len,DWORD *iLen)
{
	//EnterCriticalSection(&cs);
	WriteFile(COM,pbuf,len,iLen,NULL);
	//LeaveCriticalSection(&cs);
	return 0;
}
void dump_data(unsigned char *data,unsigned int len)
{
    puts("dump:");
    for(int i =0;i<len;i++)
    {
        printf("%02x ",data[i]);
        if((i+1)%16 == 0)
        {
            puts("");
        }
    }
    puts("");
}
int usart_recv(HANDLE COM,unsigned char *pbuf,unsigned int len)
{
    DWORD iLen;
    DWORD rCount;
    unsigned int i=0;
    BOOL bReadStat;
    iLen = len;
    unsigned int count=0;
    while(1)
    {
        bReadStat = ReadFile(COM,pbuf + i,iLen,&rCount,NULL);
        if(bReadStat)
        {
            count += rCount;
            i = count;
            iLen = len - count;
        }
        else
        {
            return -1;
        }
        if(count == len)
        {
            break;
        }
    }
    return 0;
}
int DebugReset(HANDLE hComm)
{
    char ch;
    DWORD iLen;
    ch = 0xfe;//挂起CPU
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        return 0;
        usart_recv(hComm,(unsigned char*)&ch,1);
        if((unsigned char)ch == 0xfe)
        {
            return 0;
        }
        else
        {
            GDB_printf("error retcode 0x%x",(unsigned char)ch);
            return 1;
        }
    }
    return -1;
}
int HaltCPU(HANDLE hComm)
{
    char ch;
    DWORD iLen;
    ch = 0x70;//挂起CPU
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == 0x70)
        {
            return 0;
        }
        else
        {
            GDB_printf("error retcode 0x%x",(unsigned char)ch);
            return 1;
        }
    }
    return -1;
}
/**
 * @brief 复位CPU，注：只要在cpu处于挂起态时才能复位cpu，cpu处于运行态时，只会复位外设
 * 
 * @param hComm 
 * @return int 
 */
int ResetCPU(HANDLE hComm)
{
    unsigned char ch;
    DWORD iLen;
    ch = 0xf0;//
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == 0xf0)
        {
            return 0;
        }
        else
        {
            GDB_printf("error retcode 0x%x",(unsigned char)ch);
            return 1;
        }
    }
    return -1;
}
/**
 * @brief 使halted态的CPU运行单条机器指令
 * 
 * @param hComm 
 * @return int 
 */
int StepiCPU(HANDLE hComm)
{
    char ch;
    DWORD iLen;
    ch = 0x69;//
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == 0x69)
        {
            return 0;
        }
        else
        {
            GDB_printf("error retcode 0x%x",(unsigned char)ch);
            return 1;
        }
    }
    return -1;
}
/**
 * @brief 使CPU进入运行态
 * 
 * @param hComm 
 * @return int 
 */
int ResumeCPU(HANDLE hComm)
{
    char ch;
    DWORD iLen;
    ch = 0x71;//
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == 0x71)
        {
            return 0;
        }
        else
        {
            GDB_printf("error retcode 0x%x",(unsigned char)ch);
            return 1;
        }
    }
    return -1;
}
int DebugStatus(HANDLE hComm,unsigned char*rdata)
{
    char ch;
    DWORD iLen;
    unsigned char buf[2];
    ch = 0x68;//
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,buf,2);
        if(ch != buf[0])
        {
            puts("halt read error");
        }
        *rdata = buf[1];
        return 0;
        
    }
    return -1;
}
/**
 * @brief 检查cpu是否处于halt态，常用于检查CPU是否执行到断点
 * 
 * @param hComm 
 * @return int 
 * -1 error
 *  0 CPU处于运行态
 *  1 CPU处于挂起态
 */
int CPUisHalted(HANDLE hComm)
{
    unsigned char rdata;
    int ret;
    int stat;
    stat=DebugStatus(hComm,&rdata);
    if(stat == 0)
    {
        // printf("cpu status %02x\r\n",rdata);
        return rdata&1;
    }
    else
    {
        puts("DebugStatus error");
        return 0;
    }
}
int DebugMemCtlWrite(HANDLE hComm,unsigned int value)
{
    char buf[9]={0x74,0};
    DWORD iLen;
    char ch;
    buf[1] = (value>>24)&0xff;
    buf[2] = (value>>16)&0xff;
    buf[3] = (value>>8)&0xff;
    buf[4] = (value>>0)&0xff;
    usart_send(hComm,buf,5,&iLen);
    if(iLen == 5)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == buf[0])
        {
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}
int DebugMemCtlRead(HANDLE hComm,unsigned int *value)
{
    char buf[9]={0x75,0};
    DWORD iLen;
    char ch;
    usart_send(hComm,buf,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)buf,5);
        if(ch == buf[0])
        {
            *value = (buf[1] << 24) | (buf[2] << 16) | (buf[3] << 8) | (buf[4] << 0);
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}

int DebugMemAddrWrite(HANDLE hComm,unsigned int addr)
{
    unsigned char buf[9]={0x76,0};
    DWORD iLen;
    unsigned char ch=0x76;
    if(addr&3 != 0)
    {
        while(1);
    }
    buf[1] = (addr>>24)&0xff;
    buf[2] = (addr>>16)&0xff;
    buf[3] = (addr>>8)&0xff;
    buf[4] = (addr>>0)&0xff;
    dump_data(buf,5);
    printf("addr set %08x\r\n",addr);
    usart_send(hComm,buf,5,&iLen);
    if(iLen == 5)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == buf[0])
        {
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}
int DebugMemAddrRead(HANDLE hComm,unsigned int *addr)
{
    unsigned char buf[9]={0x77,0};
    DWORD iLen;
    unsigned char ch=0x77;
    usart_send(hComm,buf,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)buf,5);
        if(ch == buf[0])
        {
            *addr = (buf[1] << 24) | (buf[2] << 16) | (buf[3] << 8) | (buf[4] << 0);
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}

int DebugMemDataWrite(HANDLE hComm,unsigned int value,unsigned char wstr)
{
    char buf[9]={0};
    DWORD iLen;
    char ch;
    buf[0] = (wstr&0xf) | 0x90;
    buf[1] = (value>>24)&0xff;
    buf[2] = (value>>16)&0xff;
    buf[3] = (value>>8)&0xff;
    buf[4] = (value>>0)&0xff;
    ch = buf[0];
    usart_send(hComm,buf,5,&iLen);
    if(iLen == 5)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == buf[0])
        {
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}
int DebugMemDataRead(HANDLE hComm,unsigned int *value)
{
    unsigned char buf[9]={00,0};
    DWORD iLen;
    unsigned char ch=0x80;
    usart_send(hComm,&ch,1,&iLen);
    if(iLen == 1)
    {
        usart_recv(hComm,(unsigned char*)buf,5);
        if(ch == buf[0])
        {
            *value = (buf[1] << 24) | (buf[2] << 16) | (buf[3] << 8) | (buf[4] << 0);
            printf("data %08x\r\n",*value);
            return 0;
        }
        else
        {
            printf("data error  %02x\r\n",buf[0]);
            return -2;
        }
    }
    else
        return -1;
}

/**
 * @brief 通过Debug对内存写一个字的数据
 * 
 * @param hComm 
 * @param addr 
 * @param wdata 
 * @return int 
 */
int CPUmemoryWriteWord(HANDLE hComm,unsigned int addr,unsigned int wdata)
{
    int stat;
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    
    stat = DebugMemDataWrite(hComm,wdata,0xf);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        return 0;
    }
}
/**
 * @brief 通过Debug对内存读一个字的数据
 * 
 * @param hComm 
 * @param addr 
 * @param rdata 
 * @return int 
 */
int CPUmemoryReadWord(HANDLE hComm,unsigned int addr,unsigned int *rdata)
{
    int stat;
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    
    stat = DebugMemDataRead(hComm,rdata);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        return 0;
    }
}
/**
 * @brief 通过Debug对内存写半个字的数据
 * 
 * @param hComm 
 * @param addr 
 * @param wdata 
 * @return int 
 */
int CPUmemoryWriteHalfWord(HANDLE hComm,unsigned int addr,unsigned short wdata)
{
    int stat;
    unsigned char wstr;
    unsigned int data;
    addr = addr&(~1);
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    
    if((addr & 0x2) == 0x2)
    {
        wstr= 8|4;
        data = (wdata&0xffff) << 16;
    }
    else
    {
        wstr = 2|1;
        data = wdata;
    }
    stat = DebugMemDataWrite(hComm,data,wstr);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        return 0;
    }
}
/**
 * @brief 通过Debug对内存读半个字的数据
 * 
 * @param hComm 
 * @param addr 
 * @param rdata 
 * @return int 
 */
int CPUmemoryReadHalfWord(HANDLE hComm,unsigned int addr,unsigned short *rdata)
{
    int stat;
    unsigned int data;
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    stat = DebugMemDataRead(hComm,&data);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        if((addr&2) == 2)
        {
            *rdata = (data >> 16)&0xffff;
        }
        else
        {
            *rdata = (data >> 0)&0xffff;
        }
        return 0;
    }
}
/**
 * @brief 通过Debug对内存写一个字节的数据
 * 
 * @param hComm 
 * @param addr 
 * @param wdata 
 * @return int 
 */
int CPUmemoryWriteByte(HANDLE hComm,unsigned int addr,unsigned char wdata)
{
    int stat;
    unsigned char wstr;
    unsigned int data;
    addr = addr;
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    
    switch (addr&3)
    {
    case 0:
        wstr = 1;
        data = wdata&0xff;
        break;
    case 1:
        wstr = 2;
        data = (wdata&0xff) << 8;
        break;
    case 2:
        wstr = 4;
        data = (wdata&0xff) << 16;
        break;
    case 3:
        wstr = 8;
        data = (wdata&0xff) << 24;
        break;
    }
    stat = DebugMemDataWrite(hComm,data,wstr);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        return 0;
    }
}

/**
 * @brief 通过Debug对内存读半个字的数据
 * 
 * @param hComm 
 * @param addr 
 * @param rdata 
 * @return int 
 */
int CPUmemoryReadByte(HANDLE hComm,unsigned int addr,unsigned char *rdata)
{
    int stat;
    unsigned int data;
    stat = DebugMemCtlWrite(hComm,0);//not burst write
    if(stat != 0)
    {
        return 1;
    }
    
    stat = DebugMemAddrWrite(hComm,addr&(~3));
    if(stat != 0)
    {
        return 2;
    }
    
    stat = DebugMemDataRead(hComm,&data);
    if(stat != 0)
    {
        return 3;
    }
    else 
    {
        printf("adr %d data %08x\r\n",addr&3,data);
        switch (addr&3)
        {
        case 0:
            *rdata = data&0xff;
            break;
        case 1:
            *rdata = (data >> 8)&0xff;
            break;
        case 2:
            *rdata = (data >> 16)&0xff;
            break;
        case 3:
            *rdata = (data >> 24)&0xff;
            break;
        }
        return 0;
    }
}
int CPU_GeneralRegisterWrite(HANDLE hComm,unsigned int index,unsigned int wdata)
{
    unsigned char buf[6] = {0x73};
    DWORD iLen;
    unsigned char ch;
    buf[1] = index;//通用寄存器编号
    buf[2] = (wdata >> 24)&0xff;
    buf[3] = (wdata >> 16)&0xff;
    buf[4] = (wdata >> 8 )&0xff;
    buf[5] = (wdata >> 0 )&0xff;
    usart_send(hComm,buf,6,&iLen);
    if(iLen == 6)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == buf[0])
        {
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}
int CPU_GeneralRegisterRead(HANDLE hComm,unsigned int index,unsigned int *rdata)
{
    unsigned char buf[6] = {0x72};
    unsigned char ch=0x72;
    DWORD iLen;
    buf[1] = index;//通用寄存器编号
    usart_send(hComm,buf,2,&iLen);
    if(iLen != 2)
        return -1;
    usart_recv(hComm,buf,5);
    if(ch == buf[0])
    {
        *rdata = (buf[1] << 24) | (buf[2] << 16) | (buf[3] << 8) | (buf[4] << 0);
        return 0;
    }
    else
    {
        return -2;
    }
}

int CPU_HardBreakPointWrite(HANDLE hComm,unsigned int index,unsigned int wdata)
{
    unsigned char buf[6] = {0x79};
    DWORD iLen;
    unsigned char ch=0x79;
    buf[1] = index;//通用寄存器编号
    buf[2] = (wdata >> 24)&0xff;
    buf[3] = (wdata >> 16)&0xff;
    buf[4] = (wdata >> 8 )&0xff;
    buf[5] = (wdata >> 0 )&0xff;
    usart_send(hComm,buf,6,&iLen);
    if(iLen == 6)
    {
        usart_recv(hComm,(unsigned char*)&ch,1);
        if(ch == buf[0])
        {
            return 0;
        }
        else
        {
            return -2;
        }
    }
    else
        return -1;
}
int CPU_HardBreakPointRead(HANDLE hComm,unsigned int index,unsigned int *rdata)
{
    unsigned char buf[6] = {0x78};
    unsigned char ch = 0x78;
    DWORD iLen;
    buf[1] = index;//通用寄存器编号
    usart_send(hComm,buf,2,&iLen);
    if(iLen != 2)
        return -1;
    usart_recv(hComm,buf,5);
    if(ch == buf[0])
    {
        *rdata = (buf[1] << 24) | (buf[2] << 16) | (buf[3] << 8) | (buf[4] << 0);
        return 0;
    }
    else
    {
        return -2;
    }
}
int CPU_HardBreakPointAdd(HANDLE hComm,unsigned int addr)
{
    unsigned int i;
    int stat = 0;
    unsigned int rdata;
    for(i=0; i < 2; i++)
    {
        if(0 == (stat = CPU_HardBreakPointRead(hComm,i,&rdata)) )
        {
            if( (rdata&(~1)) != 1)
            {
                if(0==CPU_HardBreakPointWrite(hComm,i,addr|1))
                {
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
            else
            {
                rdata = rdata&(~1);
                addr = addr&(~1);
                if(rdata == addr)
                {
                    return 0;
                }
                continue;
            }
        }
    }
    return 2;
}
int CPU_HardBreakPointDel(HANDLE hComm,unsigned int addr)
{
    unsigned int i;
    int stat = 0;
    unsigned int rdata;
    for(i=0; i < 2; i++)
    {
        if(0 == (stat = CPU_HardBreakPointRead(hComm,i,&rdata)) )
        {
            if( (rdata&(~1)) == 1)
            {
                if(0!=CPU_HardBreakPointWrite(hComm,i,addr|1))
                {
                    return 1;
                }
            }
            
        }
    }
    return 0;
}