uint8_t *ip;
uint16_t *stack, *ivt;

/* xxx - need to validate CS, EIP, SS and ESP here */

ip = FP_TO_LINEAR(ctx->cs, ctx->eip);
ivt = (uint16_t*) 0;
stack = (uint16_t*) FP_TO_LINEAR(ctx->ss, ctx->esp);

switch (ip[0])
{
case 0xcd:  /* INT n */
    stack -= 3;
    ctx->esp = ((ctx->esp & 0xffff) - 6) & 0xffff;

    stack[0] = (uint16_t) (ctx->eip + 2);
    stack[1] = ctx->cs;
    stack[2] = (uint16_t) ctx->eflags;

    if (current->v86_if)
        stack[2] |= EFLAG_IF;
    else
        stack[2] &= ~EFLAG_IF;

    current->v86_if = false;
    ctx->cs = ivt[ip[1] * 2 + 1];
    ctx->eip = ivt[ip[1] * 2];
    return true;  /* continue execution */

default:  /* something wrong */
    return false; /* terminate the app */
}