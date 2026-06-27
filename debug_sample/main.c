
#define LED (*((volatile unsigned int*)(0x01000000)))
unsigned int get()
{
    unsigned int k;
    k=~LED;
    k = k&0x3f;
    return k;
}
void delay(unsigned int count)
{volatile int i;
    for (i = 0; i < count; i++)
    {
        /* code */
    }
    
}
output(unsigned int data)
{
    delay(100);
    data = data&0x3f;
    LED = ~data;
}
void main()
{
    int i,j;
    LED = ~1;
    while(1)
    for(i =0; i< 65535;i++)
    {
        j = get();
        j = (j << 1) | (j >> 5);
        output(j);
    }
}