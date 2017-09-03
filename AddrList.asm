PrintSZ segment
	g_OptionsPrint	    db	"Address Book:",0Ah,0Dh,"$"; 用来存放打印的信�?
    g_Options0		    db	"0.	TurnOff AddressList",0Ah,0Dh,"$"
	g_Options1		    db	"1.	Add 	Infomation",0Ah,0Dh,"$"
	g_Options2		    db	"2.	Search	Infomation",0Ah,0Dh,"$"
    g_Options3          db  "<<<$"
    g_UnexceptedOption  db  "Unexcepted Options!$"
    g_CompleteSearch    db  "Completed.",0Ah,0Dh,"$"
    g_Start             db  "*****************",0Ah,0Dh,"$"
    g_Colon             db  " -:- $"
    g_NewLine           db  0Ah,0Dh,"$"
    g_szName            db  "Name:",0Ah,0Dh,"$"
    g_szTel             db  "Tel:",0Ah,0Dh,"$"
    g_Count             dw  0000h
    g_List              db  960 dup('$')
PrintSZ ends

MyStack segment stack 
	;db 100 dup(?)
	org 64
MyStack ends

AddrListCode segment
START:
    mov ax, PrintSZ
    mov ds, ax
    mov es, ax
    mov ax, MyStack
    mov ss, ax

PRINTINFO:
    ;   输出基本信息
    mov dx, offset g_OptionsPrint
	mov ah, 9h
	int 21h

	mov dx, offset g_Options0
	mov ah, 9h
	int 21h
	
	mov dx, offset g_Options1
	mov ah, 9h
	int 21h
	
	mov dx, offset g_Options2
	mov ah, 9h
	int 21h

	
MAINLOOP:
    ;   根据输入提供选项
    mov dx, offset g_NewLine
	mov ah, 9h
	int 21h
    mov dx, offset g_Options3
	mov ah, 9h
	int 21h
    ;   添加信息代码
    
    mov ah, 1h
    int 21h
    mov cl, al
    mov dx, offset g_NewLine
	mov ah, 9h
	int 21h
    ;   查找信息代码
    cmp cl, '1'
    jz  AddInfo

    cmp cl, '2'
    jz  SEARCH_INFO

	cmp cl, '0'
    jz EXIT_PROCESS
    jnz DEFAULT_PROCESS

    AddInfo:
        mov dx, offset g_szName
	    mov ah, 9h
	    int 21h

        ;获得List首地址
        lea di, g_List

        ;获取记录数目，算出偏移
        lea bx, g_Count ; 注意这里要考虑超出数组范围
        mov bx, [bx]
        mov cl, 6
        sal bx, cl   ;用来保存在List中的偏移
        
        ; 根据首地址+偏移，算出能空余位置的首地址，放入bx中
        lea ax, [di + bx]
        mov bx, ax

        mov di, 0   ;用来保存输入字节的偏移量
        
        INPUTNAME:
            ; 获取输入
            mov ah, 1h
            int 21h

            cmp al, 0Dh
            jz  COMPLATE_NAME
            ; 将获取到的值存放到，相应的位置
            mov [bx + di],  al
            
            inc di
            cmp di, 1fh
            jz COMPLATE_NAME ; 如果超出了缓冲区大小跳出循环
        jmp INPUTNAME
        COMPLATE_NAME:

        ;*******************************
        ;   这块代码用来循环接收电话号码
        ;*******************************
        ; 打印提示字符串“Tel”
        mov dx, offset g_NewLine
	    mov ah, 9h
	    int 21h
        mov dx, offset g_szTel
	    mov ah, 9h
	    int 21h


        mov di, 0   ;用来保存输入字节的偏移量，初始偏移量位零
        INPUT_TEL:
            ; 获取输入
            mov ah, 1h
            int 21h

            cmp al, 0Dh
            jz  COMPLATE_TEL
            ; 将获取到的值存放到，相应的位置
            mov [bx + di + 20h],  al
            
            inc di
            cmp di, 1fh
            jz COMPLATE_NAME ; 如果超出了缓冲区大小跳出循环
        jmp INPUT_TEL
        COMPLATE_TEL:
        
        lea bx, g_Count ; 注意这里要考虑超出数组范围
        inc word ptr [bx]
    jmp MAINLOOP
    
    ;*******************************
    ;   这块代码用来显示，查询的信息信息
    ;*******************************
    SEARCH_INFO:
        ;   获得List首地址
        lea di, g_List

        ;*************
        ;   循环遍历记录
        ;************
        lea si, g_Count ; 注意这里要考虑超出数组范围
        mov si, [si]

        ENUMERATE_RECORD:
            ;获取记录数目，算出偏移
            dec si  ; 获得在数组中的下标
            cmp si, 0ffffh   ; 检查是枚举完成
            jz  LEAVE_ENUMERATE_RECORD
            
            ; 根据数组的下标获取实际的偏移
            mov bx, si 
            mov cl, 6h
            sal bx, cl   ;用来保存在List中的偏移
            lea dx, [bx + di]
            mov ah, 9h
            int 21h
            mov dx, offset g_Colon
            mov ah, 9h
            int 21h
            lea dx, [bx + di + 20h]
            mov ah, 9h
            int 21h
            mov dx, offset g_NewLine
            mov ah, 9h
            int 21h
            DONT_PRINT:

        jmp ENUMERATE_RECORD
        LEAVE_ENUMERATE_RECORD:
        mov dx, offset g_CompleteSearch
        mov ah, 9h
        int 21h
    jmp MAINLOOP

	
    DEFAULT_PROCESS:
        mov dx, offset g_UnexceptedOption
	    mov ah, 9h
	    int 21h
        mov dx, offset g_NewLine
	    mov ah, 9h
	    int 21h
    jmp PRINTINFO

EXIT_PROCESS:
	mov	ax,	4c00h
	int 21h
	ret
AddrListCode ends
end  START
