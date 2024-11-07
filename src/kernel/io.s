.global io_outb
.global io_inb
.global io_wait

io_outb:
    mov    %rdi, %rdx
    mov    %sil, %al
    out    %al, %dx
    ret

io_inb:
    mov    %rdi, %rdx
    in     %dx, %al
    ret

io_wait:
    jmp io_wait_jmp
io_wait_jmp:
    ret
    
