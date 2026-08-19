#include <windows.h>

static int mapped(HKL layout, UINT vk, UINT scan, int shift, WCHAR expected)
{
    BYTE state[256] = {0};
    WCHAR output[8] = {0};
    if (shift) state[VK_SHIFT] = 0x80;
    return ToUnicodeEx(vk, scan, state, output, 8, 0, layout) == 1 && output[0] == expected;
}

void mainCRTStartup(void)
{
    int failed = 0;
    HKL layout = GetKeyboardLayout(0);
    if (!layout) ExitProcess(100);
    failed += !mapped(layout, VK_OEM_4, 0x1a, 0, 0x00e5);
    failed += !mapped(layout, VK_OEM_4, 0x1a, 1, L'{');
    failed += !mapped(layout, VK_OEM_1, 0x27, 0, 0x00f6);
    failed += !mapped(layout, VK_OEM_1, 0x27, 1, L':');
    failed += !mapped(layout, VK_OEM_7, 0x28, 0, 0x00e4);
    failed += !mapped(layout, VK_OEM_7, 0x28, 1, L'"');
    failed += !mapped(layout, '2', 0x03, 1, L'@');
    failed += !mapped(layout, '3', 0x04, 1, L'#');
    failed += !mapped(layout, VK_OEM_2, 0x35, 1, L'?');
    ExitProcess(failed);
}
