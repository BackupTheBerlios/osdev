#include <stdio.h>
#include <string.h>

void main() {
  char VendorSign[13];   //We need somewhere to store our vendorstring
  unsigned long MaxEAX;  //This will be used to store the maximum EAX
                         //possible to call CPUID with.

  asm {
    XOR       EAX,                        EAX
    //An efficient alternatvie to MOV EAX, 0x0

    CPUID
    //This instruction will load our registers with the data we need.

    MOV       dword ptr [VendorSign],     EBX
    //Copy the first 4 bytes in the VendorString from EBX.

    MOV       dword ptr [VendorSign+4],   EDX
    //Copy the next 4 bytes.

    MOV       dword ptr [VendorSign+8],   ECX
    //Copy the next 4 bytes.

    MOV       dword ptr MaxEAX,           EAX
    //EAX contains the maximum value to call CPUID with. Copy it to the
    //MaxEAX variable.
  }
  VendorSign[12]=0;  //The last character in the VendorSign can be anything.
                     //To make sure that it stops at the last character we add
                     //a zero character at the end


  printf("Vendor string: %s\n", VendorSign);
  printf("Maximum EAX value: %i\n", MaxEAX);
  
}