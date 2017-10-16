#include <stdio.h>

/*
 * Has almost the same checks as the actual method 7 in VXE380
 */
int user_client_1_method_7 (int width, int surface_id) {


    int r10 = width + 0x14; // r19 + 0x14
    int r8 = r10 & 0xffff;

    // ui16Width check
    if (r8 < 0x7f) {
        // loc_fffffff006dfe89c
        printf("[*]: loc_fffffff006dfe89c\n");
        printf("VXE380UC ERROR: VideoParams->ui16Width = %d.\n", r8);
        return 1;
    }

    // ui16FrameHeight check
    int r9 = r10 >> 0x10;
    if (r9 <= 0x3F) {
        printf("[*]: Failed at first check\n");
        // loc_fffffff006dfe8c4
        printf("VXE380UC ERROR: VideoParams->ui16FrameHeight = %d.\n", r9);
        return 1;
    }

    // Check (loc_fffffff006dfe7f8)
    int r11 = 0x0 + 0x148; // r20 (this) + 0x148 | TODO: We can't really do anything w 0x0
    if (r11 == 0xf6) {
        // loc_fffffff006dfe850
        if ((r10 & 0xffff) >= 0xff1) {
            printf("[*]: loc_fffffff006dfe850\n");
            printf("VXE380UC ERROR: VideoParams->ui16Width = %d.\n", r8);
            return 1;
        }
    }

    // Another ui16Width check (loc_fffffff006dfe814)
    if ((r10 & 0xffff) >= 0x7f1) {
        printf("[INFO]: Given failed value is: 0x%x\n", (r10 & 0xffff));
        printf("[*]: loc_fffffff006dfe814\n");
        printf("VXE380UC ERROR: VideoParams->ui16Width = %d.\n", r8);
        return 1;
    }

    // Another ui16FrameHeight check (loc_fffffff006dfe8bc)
    if (r9 >= 0x7f1) {
        printf("[*]: Failed at second check\n");
        // loc_fffffff006dfe8c4
        printf("VXE380UC ERROR: VideoParams->ui16FrameHeight = %d.\n", r9);
        return 1;

    }

    // SlicesPerField check (loc_fffffff006dfe8bc)
    if (r9 < 0x7f1) {
        // loc_fffffff006dfe8f8
        if ((r10 >> 0x14) * (r8 >> 0x4) >> 0x7 < 0x7f) {

            // Check SlicesPerField (loc_fffffff006dfe924)
            r8 = surface_id;
            if ((r8 >= 0x9) || (r8 == 0x0)) {
                // loc_fffffff006dfea40
                printf("VXE380UC ERROR: VideoParams->ui8SlicesPerField  = %d.\n", r8);
                return 1;
            }
        }

    } else {
        // loc_fffffff006dfe8c4
        printf("VXE380UC ERROR: VideoParams->ui16FrameHeight = %d.\n", r9);
        return 1;
    }

    return 0; // Success!
}

int main() {

    for(int i=0; i < 100000; i++) {
        
        int width = 0x400049 + i; // r8
        int surface_id = 8; // there's a check if surface id is 9 or over

        printf("[INFO]: Trying 0x%x\n", width);

        if  (user_client_1_method_7(width, surface_id) == 0) {
            printf("[*] Success! Your uiWidth [0x14] input should be: 0x%x\n", width);
            break;
        }
    }
    
    return 0;
}