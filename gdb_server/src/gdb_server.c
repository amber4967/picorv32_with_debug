#include"gdb_server.h"
#include<string.h>
#include<stdio.h>
#include<stdlib.h>

#include <conio.h>
#include <sys/stat.h>
#include<windows.h>
#include"riscv_cpu_handle.h"
#define assert(x) x
typedef struct riscv_breakpoint
{
  struct riscv_breakpoint *next;
  unsigned int addr;
  unsigned int riscv_inst;
}riscv_breakpoint;
riscv_breakpoint *pbreak_point = NULL;
HANDLE Com;
char *recvbuf;
static unsigned pc=0x2bc;
unsigned int recv_index=0;
int riscv_break_point_insert(unsigned int type ,unsigned int addr,unsigned int length)
{
  riscv_breakpoint *temp_breakpointe;
  unsigned int temp_inst;
  if(NULL == pbreak_point)
  {
    pbreak_point = (riscv_breakpoint*)malloc(sizeof(riscv_breakpoint));
    if(pbreak_point != NULL)
    {
      pbreak_point->addr = addr;
      pbreak_point->next = NULL;
      if(0 != CPUmemoryReadWord(Com,addr,&temp_inst))
      {
        free(pbreak_point);
        pbreak_point = NULL;
        return -1;
      }
      else
      {
        pbreak_point->riscv_inst = temp_inst;
        temp_inst = 0x00100073;
        if(0 == CPUmemoryWriteWord(Com,addr,temp_inst))
        {
          puts("insert breakpoint successful");
          return 0;
        }
        else
        {
          free(pbreak_point);
          pbreak_point = NULL;
          return -2;
        }
      }
    }
  }
  else
  {
    temp_breakpointe = pbreak_point;
    while(temp_breakpointe->next != NULL)
    {
      temp_breakpointe = temp_breakpointe->next;
    }
    temp_breakpointe->next = (riscv_breakpoint*)malloc(sizeof(riscv_breakpoint));
    if(temp_breakpointe->next != NULL)
    {
      temp_breakpointe->next->addr = addr;
      temp_breakpointe->next->next = NULL;
      if(0 != CPUmemoryReadWord(Com,addr,&temp_inst))
      {
        free(temp_breakpointe->next);
        temp_breakpointe->next = NULL;
        return -1;
      }
      else
      {
        if(temp_inst == 0x00100073)//“—æ≠ «∂œµ„Œﬁ–Ë‘Ÿ¥Ú∂œµ„
        {
          free(temp_breakpointe->next);
          temp_breakpointe->next = NULL;
          return 0;
        }
        temp_breakpointe->next->riscv_inst = temp_inst;
        temp_inst = 0x00100073;
        if(0 == CPUmemoryWriteWord(Com,addr,temp_inst))
        {
          puts("insert breakpoint successful");
          return 0;
        }
        else
        {
          free(temp_breakpointe->next);
          temp_breakpointe->next = NULL;
          return -2;
        }
      }
    }
  }
}
int riscv_break_point_remove(unsigned int type ,unsigned int addr,unsigned int length)
{
  riscv_breakpoint *temp1_breakpointe,*temp2_breakpointe;
  unsigned int temp_inst;
  if(pbreak_point != NULL)
  {
    temp1_breakpointe = pbreak_point;
    while((temp1_breakpointe != NULL)&&(temp1_breakpointe->addr != addr))
    {
      temp1_breakpointe = temp1_breakpointe->next;
    }
  }
  else
  {
    return -1;
  }
  if(NULL != temp1_breakpointe)
  {
    temp_inst = temp1_breakpointe->riscv_inst;
    if(0 == CPUmemoryWriteWord(Com,addr,temp_inst))
    {
      if(temp1_breakpointe != pbreak_point)
      {
        temp2_breakpointe = pbreak_point;
        while(temp2_breakpointe->next != temp1_breakpointe)
        {
          temp2_breakpointe = temp2_breakpointe->next;
        }
        temp2_breakpointe->next = temp1_breakpointe->next;
        free(temp1_breakpointe);
      }
      else
      {
        free(pbreak_point);
        pbreak_point = pbreak_point->next;
      }
      puts("remove breakpoint successful");
      return 0;
    }
    else
    {
      return -2;
    }
  }
  else
  {
    return -3;
  }
}
unsigned int  Wordlittle2big(unsigned int le) {

    return ((le & 0xffu) << 24u)
            | ((le & 0xff00u) << 8u)
            | ((le & 0xff0000u) >> 8u)
            | ((le >> 24u) & 0xffu);
}
unsigned short  HarfWordlittle2big(unsigned short le) {

    return ((le & 0xffu) << 8u) 
            | ((le & 0xff00u) >> 8u);
}
unsigned int CheckSum(unsigned char *buf,unsigned int len)
{
    unsigned int Sum = 0;
    unsigned int i;
    for(i = 0; i < len; i++)
    {
        Sum += buf[i];
    }
    return (Sum&0xff);
}
extern void packet_empty(void);
extern int packet_write(char *buf);
void gdb_server_init(HANDLE hComm)
{
    Com = hComm;
    recvbuf = (char*)malloc(recv_len);
    if(recvbuf ==NULL)
    {
      puts("malloc error\r\n");
      exit(0);
    }
}
void send_reg_xml(void)
{
  char *buf;
  unsigned int len;
  FILE *fp;
  buf = (char*)malloc(4096);
  fp = fopen("regxml.txt","r");
  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  fread(buf,1,len,fp);
  buf[len] = 0;
  packet_write(buf);
  free(buf);
}
void send_mem_xml(void)
{
  char *buf;
  unsigned int len;
  FILE *fp;
  buf = (char*)malloc(4096);
  fp = fopen("memxml.txt","r");
  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  fread(buf,1,len,fp);
  buf[len] = 0;
  puts(buf);
  packet_write(buf);
  free(buf);
}
void send_thread_xml(void)
{
  char *buf;
  unsigned int len;
  FILE *fp;
  buf = (char*)malloc(4096);
  fp = fopen("threadxml.txt","r");
  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  fread(buf,1,len,fp);
  buf[len] = 0;
  puts(buf);
  packet_write(buf);
  free(buf);
}
unsigned int dbg_mem_read_for_m(char *pbuf,unsigned int addr,unsigned int len)
{
  unsigned int i,rtn = 0;
  unsigned int temp_u32;
  unsigned short temp_u16;
  unsigned char temp_u8;
  unsigned char buf[4];
  if(addr>(4096))
  {
    printf("error addr %x\r\n",addr);
    return 1;
  }
  DebugMemCtlWrite(Com,1);
  DebugMemAddrWrite(Com,addr&(~3));
  for(i = 0; i < len; )
  {
    if(0 != DebugMemDataRead(Com,&temp_u32))
    {
      printf("%d block read error\r\n",i);
      return 1;
    }
    buf[0] = temp_u32&0xff;
    buf[1] = (temp_u32 >> 8)&0xff;
    buf[2] = (temp_u32 >> 16)&0xff;
    buf[3] = (temp_u32 >> 24)&0xff;
    if(i==0)
    {
      switch (addr&3)
      {
      case 0:
        sprintf(pbuf+i*2,"%02x",buf[0]);
        i++;
        if(len > 1)
        {
          sprintf(pbuf+i*2,"%02x",buf[1]);
          i++;
        }
        if(len > 2)
        {
          sprintf(pbuf+i*2,"%02x",buf[2]);
          i++;
        }
        if(len > 3)
        {
          sprintf(pbuf+i*2,"%02x",buf[3]);
          i++;
        }
        break;
      
      case 1:
        sprintf(pbuf+i*2,"%02x",buf[1]);
        i++;
        if(len > 1)
        {
          sprintf(pbuf+i*2,"%02x",buf[2]);
          i++;
        }
        if(len > 2)
        {
          sprintf(pbuf+i*2,"%02x",buf[3]);
          i++;
        }
        break;
      case 2:
        sprintf(pbuf+i*2,"%02x",buf[2]);
        i++;
        if(len > 1)
        {
          sprintf(pbuf+i*2,"%02x",buf[3]);
          i++;
        }
        break;
      case 3:
        sprintf(pbuf+i*2,"%02x",buf[3]);
        i++;
        break;
      }
    }
    else if((len-i) < 4)
    {
      switch (len-i)
      {
      case 1:
        sprintf(pbuf+i*2,"%02x",buf[0]);
        break;
      
      case 2:

        sprintf(pbuf+i*2,"%02x%02x",buf[0],buf[1]);
        break;
      case 3:
        sprintf(pbuf+i*2,"%02x%02x%02x",buf[0],buf[1],buf[2]);
        break;
      }
      i+=4;
      break;
    }
    else
    {
      sprintf(pbuf+i*2,"%02x%02x%02x%02x",buf[0],buf[1],buf[2],buf[3]);
      i+=4;
    }
  }
  return rtn;
}
unsigned int dbg_mem_write_for_M(char *pbuf,unsigned int addr,unsigned int len)
{
  char tempbuf[10];
  unsigned int i,rtn = 0u;
  unsigned int temp_u32;
  unsigned short temp_u16;
  unsigned char wstrb=0;
  DebugMemCtlWrite(Com,1);
  DebugMemAddrWrite(Com,addr&(~3));
  for(i = 0; i < len;)
  {
      if(i == 0)
      {
        switch ((addr&(3)))
        {
        case 0:
          temp_u32 = pbuf[0];
          wstrb = 1;
          i++;
          if(len>1)
          { 
            temp_u32 |= pbuf[1] << 8;
            wstrb |= 2;
            i++;
          }
          if(len>2)
          { 
            temp_u32 |= pbuf[2] << 16;
            wstrb |= 4;
            i++;
          }
          if(len>3)
          { 
            temp_u32 |= pbuf[3] << 24;
            wstrb |= 8;
            i++;
          }
          break;
        
        case 1:
          temp_u32 = pbuf[0] << 8;
          wstrb =2;
          i++;
          if(len>1)
          {
            temp_u32 |= pbuf[1] << 16;
            wstrb |= 4;
            i++;
          }
          if(len>2)
          {
            temp_u32 |= pbuf[2] << 24;
            wstrb |= 8;
          }
          i+=3;
          break;
        case 2:
          temp_u32 = pbuf[0] << 16;
          wstrb = 4;
          i++;
          if(len>1)
          {
            temp_u32 |= pbuf[1] << 24;
            wstrb |= 8;
            i++;
          }
          break;
        case 3:
          temp_u32 = pbuf[0] << 24;
          wstrb = 8;
          i+=1;
          break;
        }
      }
      else if((len-i)<4)
      {
        i+=4;
        switch (len-i)
        {
        case 1:
          temp_u32 = pbuf[i];
          wstrb = 1;
          
          break;
        
        case 2:
          temp_u32 = pbuf[i];
          temp_u32 |= pbuf[i+1] << 8;
          wstrb = 1 | 2;
          break;
        case 3:
          temp_u32 = pbuf[i];
          temp_u32 |= pbuf[i+1] << 8;
          temp_u32 |= pbuf[i+2] << 16;
          wstrb = 1 | 2 | 4;
          break;
        }
      }
      else
      {
        temp_u32 = pbuf[i];
        temp_u32 |= pbuf[i+1] << 8;
        temp_u32 |= pbuf[i+2] << 16;
        temp_u32 |= pbuf[i+3] << 24;
        wstrb = 1 | 2 | 4 | 8;
        i+=4;
      }
      if(0 != DebugMemDataWrite(Com,temp_u32,wstrb))
      {
        return 1;
      }
  }
  return rtn;
}
void process_xfer(const char *name, char *args)
{
  const char *mode = args;
  args = strchr(args, ':');
  *args++ = '\0';
  puts(name);
  if (!strcmp(name, "features") && !strcmp(mode, "read"))
    send_reg_xml();
  if (!strcmp(name, "threads") && !strcmp(mode, "read"))
    send_thread_xml();
  if (!strcmp(name, "memory-map") && !strcmp(mode, "read"))
  {
    send_mem_xml();
  }
  if(!strcmp(name,"exec-file"))
  {
    packet_write("");
  }
}
char* hex2str(char*hex)
{
  unsigned int str_len,i;
  char *str;
  char tempbuf[3]={0};
  str_len = strlen(hex)/2;
  str = (char*)malloc(str_len + 1);
  if(str == NULL)
  {
    return str;
  }
  memset(str,0,str_len + 1);
  for(i = 0; i < str_len; i++)
  {
    memcpy(tempbuf,hex + i*2,2);
    sscanf(tempbuf,"%x",str + i);
  }
  return str;
}
char* str2hex(char*str)
{
  unsigned int hex_len,i;
  char *hex;
  hex_len = strlen(str)*2 + 1;
  hex = (char*)malloc(hex_len);
  if(hex == NULL)
  {
    return hex;
  }
  memset(hex,0,hex_len);
  for(i = 0; i < strlen(str); i++)
  {
    sprintf(hex+i*2,"%02x",str[i]);
  }
  return hex;
}
int monitor_handle(char* args)
{
  char *str;
  int rtn;
  unsigned int rdata;
  if(*args == '\0')
  {
    str = str2hex(" reset_halt :reset and halt cpu\r\nmonitor output finish\r\n");
    if(str == NULL)
    return 0;
    packet_write(str);
    free(str);
    return 0;
  }
  str = hex2str(args);
  if(str != NULL)
  {
    if(!strcmp(str,"reset_halt"))
    {
      HaltCPU(Com);
      ResetCPU(Com);
      CPU_GeneralRegisterWrite(Com,0x3f,0);
      packet_write("OK");
    }
  }
  else
  {
    packet_write("E 05");
  }
  if(str != NULL)
  {
    free(str);
  }
  return 0;
}
extern unsigned int ack_flag;
void process_query(char *payload)
{
  const char *name;
  char *args;
  args = strchr(payload, ':');
  if (args)
    *args++ = '\0';
  name = payload;
  puts(name);
  if(NULL != strstr(name,"Rcmd"))
  {
    args = strchr(payload, ',');
    if (args)
      *args++ = '\0';
    monitor_handle(args);
  }
  if(!strcmp(name,"StartNoAckMode"))
  {
    ack_flag = 0;
    packet_write("OK");
  }
  if (!strcmp(name, "C"))
  {
    //snprintf(tmpbuf, sizeof(tmpbuf), "QCp%02x.%02x", threads.curr->pid, threads.curr->tid);
    // packet_write(tmpbuf);
    packet_write("");
  }
  if(!strcmp(name,"L"))
  {
    packet_write("qM0100000000000000000");
  }
  if (!strcmp(name, "Attached"))
  {

    if(1)// (attach)
      packet_write("1");
    else
      packet_write("0");
  }
  if (!strcmp(name, "Offsets"))
    packet_write("Text=0;Data=0;Bss=0");;
  if (!strcmp(name, "Supported"))
  {
    packet_write("PacketSize=1000;qXfer:memory-map:read+;qXfer:features:read+;qXfer:threads:read-;QStartNoAckMode+;vContSupported+");
    ack_flag = 1;
  }
  if (!strcmp(name, "Symbol"))
    packet_write("OK");
  if (name == strstr(name, "ThreadExtraInfo"))
  {
    args = payload;
    args = 1 + strchr(args, ',');
    //packet_write("41414141");
    packet_write("");
  }
  if (!strcmp(name, "TStatus"))
    packet_write("");;
  if (!strcmp(name, "Xfer"))
  {
    name = args;
    args = strchr(args, ':');
    *args++ = '\0';
    return process_xfer(name, args);
  }
  if (!strcmp(name, "fThreadInfo"))
  {
    
    packet_write("m0000l");
  }
  if (!strcmp(name, "sThreadInfo"))
  {
    // packet_write("l");
    packet_write("");
  }
}
unsigned int process_vpacket(char *payload)
{
  const char *name;
  unsigned int rtn = 0;
  int ret;
  char *args;
  args = strchr(payload, ';');
  if (args)
    *args++ = '\0';
  name = payload;
  puts(name);
  if (!strcmp("Cont", name))
  {
    pc += 4;
    puts(args);
    if (args[0] == 'c')
    {
      if(0 != ResumeCPU(Com))
      {
        packet_write("E 02");
      }
      else
      {
        
        char ch;
        do
        {
          ret = CPUisHalted(Com);
          if(1 == RingBufRead((char*)&ch,1))
          {
            if(ch == 3)
            {
              packet_write("T05");
              HaltCPU(Com);
              return 0;
            }
          }
        } while (ret <= 0);
        if(ret == 1)
        {
          packet_write("T05");
        }
        else
        {
          packet_write("E 02");
        }
      }
    }
    if (args[0] == 's')
    {
      int rtn;
      unsigned int flag = 0;
      unsigned int temp,temp_u32;
      puts("step");
      if(0 !=HaltCPU(Com))
      {
        packet_write("E02");
        return 0;
      }
      if(0 != (rtn = CPU_GeneralRegisterRead(Com,32,&temp)))
      {
        GDB_printf("read register error %d\r\n",rtn);
        puts("Get PC error\r\n");
      }
      if(0 == CPUmemoryReadWord(Com,temp,&temp_u32))
      {
        //
        if(temp == 0x00100073)//¥Ê‘⁄»Ì∂œµ„–Ë“™»°œ˚
        {
          flag = 1;
          riscv_break_point_remove(0,temp,4);
        }
      }
      
      if(0 != StepiCPU(Com))
      {
        packet_write("E02");
      }
      else
      {
        char ch;
        do
        {
          ret = CPUisHalted(Com);
          if(1 == RingBufRead((char*)&ch,1))
          {
            if(ch == 3)
            {
              HaltCPU(Com);
              packet_write("T05");
              return 0;
            }
          }
        } while (ret <= 0);
        if(ret == 1)
        {
          if(flag == 1)
          {
            // riscv_break_point_insert(0,temp,4);
          }
          packet_write("T05");
        }
        else
        {
          packet_write("E 02");
        }
      }
    }
    if(args[0] == 'C')
    {
      printf("C %s\r\n",args);
    }
    if(args[0] == 'S')
    {
      printf("S %s\r\n",args);
    }
    if(args[0] == 't')
    {
      printf("Stop %s\r\n",args);
    }
    if(args[0] == 'r')
    {
      printf("Start %s\r\n",args);
    }
  }
  if (!strcmp("Cont?", name))
  {
    // packet_write("T02");
    packet_write("vCont;c;C;s;S");
  }
  if (!strcmp("Kill", name))
  {
    rtn = 1;
    packet_write("OK");
  }
  if (!strcmp("MustReplyEmpty", name))
  {
    packet_write("");;
  }
  if (name == strstr(name, "File:"))
  {
    char *operation = (char*)(strchr(name, ':') + 1);
    if (operation == strstr(operation, "open:"))
    {
      
    }
    else if (operation == strstr(operation, "close:"))
    {
      char *parameter = strchr(operation, ':') + 1;
      size_t fd;
      assert(sscanf(parameter, "%zx", &fd) == 1);
      // close(fd);
      packet_write("F0");
    }
    else if (operation == strstr(operation, "pread:"))
    {
      
    }
    else if (operation == strstr(operation, "setfs:"))
    {
      
      packet_write("F0");
    }
    else
      packet_write("");;
  }
  return rtn;
}
// #define packet_debug
unsigned int process_packet()
{
  char *cmd;
  char request ;
  char *payload ;
  char *checksum;
  #ifdef packet_debug
  puts("-----------------------------------:");
  puts("process_packet:");
  puts(recvbuf);
  puts("********************************:");
  #endif
  cmd = strstr(recvbuf,"$");
  if(cmd == NULL)
  {
    return 0;
  }
 
  checksum = strstr(recvbuf,"#");
  if(checksum != NULL)
  {
    checksum[0] = 0;
  }
  // puts(cmd);
  request = cmd[1];
  payload = (char *)&cmd[2];
  switch (request)
  {
    case 'G':
    packet_write("");;
    printf("G\r\n");
    break;
  case 'D':
    //ÈèÇÓÖûÁ¥ëÊù©ÁÇ¥Â∏¥
    return 1;
  case 'g'://ÈéµÊí≥ÂµÉÁÄµÂã´Áì®Èç£Ôø???
  {
    char *membuf;
    unsigned int i,temp;
    int rtn;
    membuf = (char*)malloc(4096);
    for(i=0; i<=32; i++)
    {
      if(i == 32)
      {
        if(0 != (rtn = CPU_GeneralRegisterRead(Com,0x3f,&temp)))
        {
          GDB_printf("read register error %d\r\n",rtn);
          temp = 0;
        }
      }
      else
      {
        if(0 != (rtn = CPU_GeneralRegisterRead(Com,i,&temp)))
        {
          GDB_printf("read register error %d\r\n",rtn);
          temp = 0;
        }
      }
      
      sprintf(membuf + 8*i,"%08x",Wordlittle2big(temp));
    }
    packet_write(membuf);
    free(membuf);
    break;
  }
  case 'H':
    if ('g' == *payload++)
    {
    //   pid_t tid;
    //   char *dot = strchr(payload, '.');
    //   assert(dot);
    //   tid = strtol(dot, NULL, 16);
    //   if (tid > 0)
    //     set_curr_thread(tid);
    
    packet_write("OK");
    }
    else if('c'== *payload++)
    {
      packet_write("OK");
    }
    else
    {
      packet_write("");
    }
    
    break;
  case 'm':
  {
    unsigned int maddr, mlen,i, mdata;
    char *membuf;

    if( sscanf(payload, "%x,%x", &maddr, &mlen) == 2)
    {
      // puts(payload);
        GDB_printf("mem read addr:0x%08x size:%d\r\n",maddr,mlen);
        
        membuf = (char*)malloc(mlen*2+10);
        memset(membuf,0,mlen*2+10);
        if(0 == dbg_mem_read_for_m(membuf,maddr,mlen))
        {
          packet_write(membuf);
        }
        else
        {
          packet_write("E02");
        }
        free(membuf);
    }
    else
    {
        printf("mem read error\r\n");
        packet_write("OK");
    }
    
    
    break;
  }
  case 'M':
  {
    unsigned int maddr, mlen, mdata;
    if(sscanf(payload, "%x,%x:", &maddr, &mlen) == 2)
    {
      puts(payload);
        GDB_printf("write mem addr:0x%08x size:%d\r\n",maddr,mlen);

        if(0 == dbg_mem_write_for_M(strchr(payload,':') + 1,maddr,mlen))
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E02");
        }
    }
    else
    {
      printf("mem write error\r\n");
      packet_write("E 02");
    }
    break;
  }
  case 'p':
  {
    //ÁíáËØ≤ÂΩáÁÄµÂã´Áì®Èç£„Ñ•‚Ç¨Ôø???
    char *reg_index;
    char *tempbuf;
    int rtn;
    unsigned int read_reg_value,temp;
    unsigned int cpu_reg_index=0;
    reg_index = payload;
    sscanf(reg_index,"%zx",&cpu_reg_index);
    if(cpu_reg_index <= 32)
    {
      
      if(cpu_reg_index == 32)
      {
        if(0 != (rtn = CPU_GeneralRegisterRead(Com,0x3f,&read_reg_value)))
        {
          GDB_printf("read register error %d\r\n",rtn);
          read_reg_value = 0;
        }
      }
      else
      {
        if(0 != (rtn = CPU_GeneralRegisterRead(Com,cpu_reg_index,&read_reg_value)))
        {
          GDB_printf("read register error %d\r\n",rtn);
          read_reg_value = 0;
        }
      }
    }
    else//csrÔøΩƒ¥ÔøΩÔøΩÔøΩ
    {
      if(0 != (rtn = CPU_GeneralRegisterRead(Com,cpu_reg_index-1,&read_reg_value)))
        {
          GDB_printf("read register error %d\r\n",rtn);
          read_reg_value = 0;
        }
    }
    printf("reg[%s] = %08x\r\n",reg_index,read_reg_value);
    read_reg_value = Wordlittle2big(read_reg_value);
    tempbuf = (char*)malloc(1024);
    sprintf(tempbuf,"%08x",read_reg_value);
    packet_write(tempbuf);
    break;
  }
  case 'P':
  {
    //ÈçêÊ¨èÁòéÁÄõÊ®∫Ê´íÈçäÔø???
    char *reg_value;
    unsigned int reg_index;
    unsigned int write_value;
    reg_value = strchr(payload,'=');
    if(reg_value != NULL)
    {
      *reg_value = 0;
      reg_value++;
      sscanf(payload,"%zx",&reg_index);
      sscanf(reg_value,"%zx",&write_value);
      write_value = Wordlittle2big(write_value);
      printf("reg %d write %08x\r\n",reg_index,write_value);
      if(reg_index <= 32)
      {
        if(reg_index == 32)
        {
          CPU_GeneralRegisterWrite(Com,0x3f,write_value);
        }
        else
        {
          CPU_GeneralRegisterWrite(Com,reg_index,write_value);
        }
        
      }
      else
      {
        CPU_GeneralRegisterWrite(Com,reg_index-1,write_value);
      }
    }
    packet_write("OK");
    break;
  }
  case 'Q':
  case 'q':
    process_query(payload);
    break;
  case 'v':
    return process_vpacket(payload);
    break;
  case 'X':
  {
    unsigned int maddr, mlen, mdata;
    int offset, new_len;
    if(sscanf(payload, "%zx,%zx:%n", &maddr, &mlen, &offset) == 2)
    {
      
    }
    payload += offset;
    packet_write("");
    //loadÁªãÂ¨™Ôø???
    break;
  }
  case 'Z':
  {
    unsigned int type, addr, length;
    if(sscanf(payload, "%x,%x,%x", &type, &addr, &length) == 3)
    {
        printf("z packet %s\r\n",payload);
        printf("Z break type: %d addr:0x%08x length:%d \r\n",type,addr,length);
        if(type == 8)
        {
        if(0 == riscv_break_point_insert(type,addr,length))
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E03");
        }
      }
      else if(type == 1)
      {
        if(0 == CPU_HardBreakPointAdd(Com,addr&(~1)) )
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E 03");
        }
      }
      else
      {
        if(0 == CPU_HardBreakPointAdd(Com,addr&(~1)) )
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E 03");
        }
      }
    }
    //Â®£ËØ≤ÂßûÈèÇÓÖ†ÂÅ£
    break;
  }
  case 'z':
  {
    size_t type, addr, length;
    if(sscanf(payload, "%x,%x,%x", &type, &addr, &length) == 3)
    {
      printf("z packet %s\r\n",payload);
      printf("z break type: %d addr:0x%08x length:%d \r\n",type,addr,length);
      if(type == 8)
      {
        printf("add hard bkpt\r\n");
        if(0 == riscv_break_point_remove(type,addr,length))
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E 03");
        }
      }
      else if(type == 1)
      {
        printf("del hard bkpt\r\n");
        if(0 == CPU_HardBreakPointDel(Com,addr&(~1)) )
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E 03");
        }
      }
      else
      {
        if(0 == CPU_HardBreakPointAdd(Com,addr&(~1)) )
        {
          packet_write("OK");
        }
        else
        {
          packet_write("E 03");
        }
      }
      
    }
    
    //ÈçôÊ†®Áß∑ÈèÇÓÖ†ÂÅ£
    break;
  }
  case '?':
    packet_write("S05");
    break;
  default:
    packet_write("");;
  }
  return 0;
}
