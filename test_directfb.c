#include <directfb.h>

int main(int argc, char *argv[]) {
    IDirectFB *dfb = NULL;

    // Initialize DirectFB
    if (DirectFBInit(&argc, &argv) != DFB_OK) {
        printf("DirectFB initialization failed.\n");
        return 1;
    }

    // Create the DirectFB interface
    if (DirectFBCreate(&dfb) != DFB_OK) {
        printf("Failed to create DirectFB interface.\n");
        return 1;
    }

    printf("DirectFB initialized successfully!\n");

    // Release the DirectFB interface
    dfb->Release(dfb);

    return 0;
}