#define VALID_FLAGS         0xDFF

bool i386V86Gpf(context_v86_t *ctx)
{
    uint8_t *ip;
    uint16_t *stack, *ivt;
    uint32_t *stack32;
    bool is_operand32, is_address32;

    ip = FP_TO_LINEAR(ctx->cs, ctx->eip);
    ivt = (uint16_t*) 0;
    stack = (uint16_t*) FP_TO_LINEAR(ctx->ss, ctx->esp);
    stack32 = (uint32_t*) stack;
    is_operand32 = is_address32 = false;
    TRACE4("i386V86Gpf: cs:ip = %04x:%04x ss:sp = %04x:%04x: ", 
        ctx->cs, ctx->eip,
        ctx->ss, ctx->esp);

    while (true)
    {
        switch (ip[0])
        {
        case 0x66:            /* O32 */
            TRACE0("o32 ");
            is_operand32 = true;
            ip++;
            ctx->eip = (uint16_t) (ctx->eip + 1);
            break;

        case 0x67:            /* A32 */
            TRACE0("a32 ");
            is_address32 = true;
            ip++;
            ctx->eip = (uint16_t) (ctx->eip + 1);
            break;
            
        case 0x9c:            /* PUSHF */
            TRACE0("pushf\n");

            if (is_operand32)
            {
                ctx->esp = ((ctx->esp & 0xffff) - 4) & 0xffff;
                stack32--;
                stack32[0] = ctx->eflags & VALID_FLAGS;

                if (current->v86_if)
                    stack32[0] |= EFLAG_IF;
                else
                    stack32[0] &= ~EFLAG_IF;
            }
            else
            {
                ctx->esp = ((ctx->esp & 0xffff) - 2) & 0xffff;
                stack--;
                stack[0] = (uint16_t) ctx->eflags;

                if (current->v86_if)
                    stack[0] |= EFLAG_IF;
                else
                    stack[0] &= ~EFLAG_IF;
            }

            ctx->eip = (uint16_t) (ctx->eip + 1);
            return true;

        case 0x9d:            /* POPF */
            TRACE0("popf\n");

            if (is_operand32)
            {
                ctx->eflags = EFLAG_IF | EFLAG_VM | (stack32[0] & VALID_FLAGS);
                current->v86_if = (stack32[0] & EFLAG_IF) != 0;
                ctx->esp = ((ctx->esp & 0xffff) + 4) & 0xffff;
            }
            else
            {
                ctx->eflags = EFLAG_IF | EFLAG_VM | stack[0];
                current->v86_if = (stack[0] & EFLAG_IF) != 0;
                ctx->esp = ((ctx->esp & 0xffff) + 2) & 0xffff;
            }
            
            ctx->eip = (uint16_t) (ctx->eip + 1);
            return true;

        case 0xcd:            /* INT n */
            TRACE1("interrupt 0x%x => ", ip[1]);
            switch (ip[1])
            {
            case 0x30:
                TRACE0("syscall\n");
                if (ctx->regs.eax == SYS_ThrExitThread)
                    ThrExitThread(0);
                return true;

            case 0x20:
            case 0x21:
                /*i386V86EmulateInt21(ctx);*/
                if (current->v86_in_handler)
                    return false;

                TRACE1("redirect to %x\n", current->v86_handler);
                current->v86_in_handler = true;
                current->v86_context = *ctx;
                current->kernel_esp += sizeof(context_v86_t) - sizeof(context_t);
                ctx->eflags = EFLAG_IF | 2;
                ctx->eip = current->v86_handler;
                ctx->cs = USER_FLAT_CODE | 3;
                ctx->ds = ctx->es = ctx->gs = ctx->ss = USER_FLAT_DATA | 3;
                ctx->fs = USER_THREAD_INFO | 3;
                ctx->esp = current->user_stack_top;
                return true;

            default:
                stack -= 3;
                ctx->esp = ((ctx->esp & 0xffff) - 6) & 0xffff;

                stack[0] = (uint16_t) (ctx->eip + 2);
                stack[1] = ctx->cs;
                stack[2] = (uint16_t) ctx->eflags;
                
                if (current->v86_if)
                    stack[2] |= EFLAG_IF;
                else
                    stack[2] &= ~EFLAG_IF;

                ctx->cs = ivt[ip[1] * 2 + 1];
                ctx->eip = ivt[ip[1] * 2];
                TRACE2("%04x:%04x\n", ctx->cs, ctx->eip);
                return true;
            }

            break;

        case 0xcf:            /* IRET */
            TRACE0("iret => ");
            ctx->eip = stack[0];
            ctx->cs = stack[1];
            ctx->eflags = EFLAG_IF | EFLAG_VM | stack[2];
            current->v86_if = (stack[2] & EFLAG_IF) != 0;

            ctx->esp = ((ctx->esp & 0xffff) + 6) & 0xffff;
            TRACE2("%04x:%04x\n", ctx->cs, ctx->eip);
            return true;

        case 0xfa:            /* CLI */
            TRACE0("cli\n");
            current->v86_if = false;
            ctx->eip = (uint16_t) (ctx->eip + 1);
            return true;

        case 0xfb:            /* STI */
            TRACE0("sti\n");
            current->v86_if = true;
            ctx->eip = (uint16_t) (ctx->eip + 1);
            return true;

        default:
            wprintf(L"unhandled opcode 0x%x\n", ip[0]);
            return false;
        }
    }

    return false;
}