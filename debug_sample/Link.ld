ENTRY( _startup )

__stack_size = 2048;

PROVIDE( _stack_size = __stack_size );


MEMORY
{
	RAM (xrw) : ORIGIN = 0x00000000, LENGTH = 4K

}


SECTIONS
{

	.init :
	{
		_sinit = .;
		. = ALIGN(4);
		KEEP(*(SORT_NONE(.init)))
		. = ALIGN(4);
		_einit = .;
	} >RAM
	.rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >RAM

	.text :
	{
		. = ALIGN(4);
		*(.text)
		*(.text.*)
		. = ALIGN(4);
		PROVIDE( _etext_ram = .);
	} >RAM AT > RAM

	.fini :
	{
		KEEP(*(SORT_NONE(.fini)))
		. = ALIGN(4);
	} >RAM

	PROVIDE( _etext = . );
	PROVIDE( _eitcm = . );	


	.dalign :
	{
		. = ALIGN(4);
		PROVIDE(_data_vma = .);
	} >RAM AT>RAM	
	.dlalign :
	{
		. = ALIGN(4); 
		PROVIDE(_data_lma = .);
	} >RAM AT>RAM
	.data :
	{
    	*(.data .data.*)
		. = ALIGN(8);
    	PROVIDE( __global_pointer$ = . + 0x000 );

    	. = ALIGN(4);
		PROVIDE( _edata = .);
	} >RAM AT > RAM

	.bss :
	{
		. = ALIGN(4);
		PROVIDE( _sbss = .);
		*(.bss*)
		*(COMMON*)
		. = ALIGN(4);
		PROVIDE( _ebss = .);
	} >RAM AT > RAM

	PROVIDE( _end = _ebss);
	PROVIDE( end = . );

    .stack ORIGIN(RAM) + LENGTH(RAM) - __stack_size :
    {
        PROVIDE( _heap_end = . );
        . = ALIGN(4);
        PROVIDE(_susrstack = . );
        . = . + __stack_size;
        PROVIDE( _eusrstack = .);
    } >RAM 

}



