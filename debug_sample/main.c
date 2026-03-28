
#define LED (*((volatile unsigned int*)(0x01000000)))
void main()
{
    int i,j;
    LED = 1;
    while(1)
    for(i =0; i< 65535;i++)
    {
        j = ~LED;
        LED = ~((j <<1) | ((j&0x20) >> 5));
    }
}