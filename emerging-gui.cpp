/**
 * Emerging GUI 编译器 - 简化版
 * 图形界面版本的 Emerging 编译器
 * 
 * 编译命令:
 * g++ -o emerging-gui.exe emerging-gui.cpp -mwindows -O2
 */

#include <windows.h>
#include <commctrl.h>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
using namespace std;

// 控件ID
#define ID_BUTTON_COMPILE    1001
#define ID_BUTTON_BROWSE     1002
#define ID_BUTTON_RUN        1003
#define ID_BUTTON_CLEAR      1004
#define ID_EDIT_SOURCE       2001
#define ID_EDIT_OUTPUT       2002
#define ID_EDIT_LOG          2003
#define ID_COMBO_PLATFORM    3001
#define ID_PATH_DISPLAY      4001

// 全局变量
HINSTANCE hInst;
HWND hEditSource, hEditOutput, hEditLog, hComboPlatform, hPathDisplay;
char szSourceFile[MAX_PATH] = "";
char szOutputFile[MAX_PATH] = "";
char szCurrentDir[MAX_PATH] = "";

// 函数声明
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
void CompileFile(HWND hWnd);
void BrowseFile(HWND hWnd);
void RunProgram(HWND hWnd);
void AddLog(const char* text);
void AddLogWithColor(const char* text, COLORREF color);
void SetStatus(const char* text);

// WinMain 入口
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    hInst = hInstance;
    
    // 初始化公共控件
    INITCOMMONCONTROLSEX icex;
    icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
    icex.dwICC = ICC_WIN95_CLASSES;
    InitCommonControlsEx(&icex);
    
    // 获取当前目录
    GetCurrentDirectory(MAX_PATH, szCurrentDir);
    
    // 注册窗口类
    WNDCLASSEX wc = {0};
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.lpszClassName = "EmergingGUI";
    wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
    
    if (!RegisterClassEx(&wc)) {
        MessageBox(NULL, "窗口注册失败!", "错误", MB_ICONERROR);
        return 0;
    }
    
    // 创建窗口
    HWND hWnd = CreateWindowEx(
        0, "EmergingGUI", "Emerging 2.0 GUI 编译器",
        WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
        CW_USEDEFAULT, CW_USEDEFAULT, 900, 700,
        NULL, NULL, hInstance, NULL
    );
    
    if (!hWnd) {
        MessageBox(NULL, "窗口创建失败!", "错误", MB_ICONERROR);
        return 0;
    }
    
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);
    
    // 消息循环
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    
    return msg.wParam;
}

// 窗口过程
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
        case WM_CREATE: {
            // 创建字体
            HFONT hFont = CreateFont(16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                                     DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                                     DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Consolas");
            
            // 创建平台选择下拉框
            CreateWindow("STATIC", "目标平台:", WS_CHILD | WS_VISIBLE,
                        10, 10, 80, 25, hWnd, NULL, hInst, NULL);
            
            hComboPlatform = CreateWindow("COMBOBOX", NULL,
                                         WS_CHILD | WS_VISIBLE | CBS_DROPDOWNLIST | WS_TABSTOP,
                                        100, 10, 150, 200, hWnd, (HMENU)ID_COMBO_PLATFORM, hInst, NULL);
            
            SendMessage(hComboPlatform, CB_ADDSTRING, 0, (LPARAM)"Windows (x64)");
            SendMessage(hComboPlatform, CB_ADDSTRING, 0, (LPARAM)"Linux (x64)");
            SendMessage(hComboPlatform, CB_ADDSTRING, 0, (LPARAM)"macOS (x64)");
            SendMessage(hComboPlatform, CB_SETCURSEL, 0, 0);
            
            // 创建按钮
            CreateWindow("BUTTON", "浏览源文件", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                        270, 10, 120, 30, hWnd, (HMENU)ID_BUTTON_BROWSE, hInst, NULL);
            
            CreateWindow("BUTTON", "编译", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                        400, 10, 100, 30, hWnd, (HMENU)ID_BUTTON_COMPILE, hInst, NULL);
            
            CreateWindow("BUTTON", "运行", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                        510, 10, 100, 30, hWnd, (HMENU)ID_BUTTON_RUN, hInst, NULL);
            
            CreateWindow("BUTTON", "清空日志", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                        620, 10, 100, 30, hWnd, (HMENU)ID_BUTTON_CLEAR, hInst, NULL);
            
            // 创建静态文本 - 源文件
            CreateWindow("STATIC", "源文件:", WS_CHILD | WS_VISIBLE,
                        10, 50, 60, 20, hWnd, NULL, hInst, NULL);
            
            // 创建源文件路径显示
            hPathDisplay = CreateWindow("EDIT", "", WS_CHILD | WS_VISIBLE | ES_READONLY | WS_BORDER,
                                        70, 48, 600, 23, hWnd, (HMENU)ID_PATH_DISPLAY, hInst, NULL);
            
            // 创建静态文本 - 源代码编辑区
            CreateWindow("STATIC", "源代码:", WS_CHILD | WS_VISIBLE,
                        10, 80, 60, 20, hWnd, NULL, hInst, NULL);
            
            // 创建源代码编辑框
            hEditSource = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "",
                                         WS_CHILD | WS_VISIBLE | ES_MULTILINE | 
                                         ES_AUTOVSCROLL | ES_AUTOHSCROLL | WS_VSCROLL | WS_HSCROLL,
                                         10, 100, 860, 250, hWnd, (HMENU)ID_EDIT_SOURCE, hInst, NULL);
            SendMessage(hEditSource, WM_SETFONT, (WPARAM)hFont, TRUE);
            
            // 设置默认源代码
            SetWindowText(hEditSource, 
                "-- Emerging 2.0 示例程序\n"
                "using \"iostream\"\n\n"
                "func main() -> int\n"
                "{\n"
                "    out(\"Hello, Emerging 2.0!\\n\")\n"
                "    ret\n"
                "}\n");
            
            // 创建静态文本 - 输出文件
            CreateWindow("STATIC", "输出文件:", WS_CHILD | WS_VISIBLE,
                        10, 360, 60, 20, hWnd, NULL, hInst, NULL);
            
            // 创建输出文件编辑框
            hEditOutput = CreateWindow("EDIT", "output.exe", WS_CHILD | WS_VISIBLE | WS_BORDER,
                                       70, 358, 200, 23, hWnd, (HMENU)ID_EDIT_OUTPUT, hInst, NULL);
            
            // 创建静态文本 - 编译日志
            CreateWindow("STATIC", "编译日志:", WS_CHILD | WS_VISIBLE,
                        10, 390, 60, 20, hWnd, NULL, hInst, NULL);
            
            // 创建日志编辑框
            hEditLog = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "",
                                      WS_CHILD | WS_VISIBLE | ES_MULTILINE | 
                                      ES_AUTOVSCROLL | ES_READONLY | WS_VSCROLL,
                                      10, 410, 860, 200, hWnd, (HMENU)ID_EDIT_LOG, hInst, NULL);
            SendMessage(hEditLog, WM_SETFONT, (WPARAM)hFont, TRUE);
            
            // 初始日志
            AddLog("Emerging 2.0 GUI 编译器已启动\n");
            AddLog("请选择源文件或直接编辑上面的代码\n");
            
            break;
        }
        
        case WM_COMMAND: {
            int wmId = LOWORD(wParam);
            
            switch (wmId) {
                case ID_BUTTON_BROWSE:
                    BrowseFile(hWnd);
                    break;
                    
                case ID_BUTTON_COMPILE:
                    CompileFile(hWnd);
                    break;
                    
                case ID_BUTTON_RUN:
                    RunProgram(hWnd);
                    break;
                    
                case ID_BUTTON_CLEAR:
                    SetWindowText(hEditLog, "");
                    AddLog("日志已清空\n");
                    break;
            }
            break;
        }
        
        case WM_SIZE: {
            // 调整控件大小
            RECT rcClient;
            GetClientRect(hWnd, &rcClient);
            int width = rcClient.right - rcClient.left - 20;
            
            SetWindowPos(hEditSource, NULL, 10, 100, width, 250, SWP_NOZORDER);
            SetWindowPos(hEditLog, NULL, 10, 410, width, rcClient.bottom - 430, SWP_NOZORDER);
            SetWindowPos(hPathDisplay, NULL, 70, 48, width - 80, 23, SWP_NOZORDER);
            break;
        }
        
        case WM_DESTROY:
            PostQuitMessage(0);
            break;
            
        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// 浏览文件
void BrowseFile(HWND hWnd) {
    OPENFILENAME ofn = {0};
    char szFile[MAX_PATH] = "";
    
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = hWnd;
    ofn.lpstrFilter = "Emerging源文件\0*.emg\0所有文件\0*.*\0";
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = MAX_PATH;
    ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
    
    if (GetOpenFileName(&ofn)) {
        strcpy(szSourceFile, szFile);
        
        // 显示文件路径
        SetWindowText(hPathDisplay, szSourceFile);
        
        // 读取文件内容到编辑框
        ifstream file(szSourceFile);
        if (file) {
            string content((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
            SetWindowText(hEditSource, content.c_str());
            
            char logMsg[256];
            sprintf(logMsg, "已加载文件: %s\n", szSourceFile);
            AddLog(logMsg);
        }
    }
}

// 编译文件
void CompileFile(HWND hWnd) {
    char source[65536] = "";
    char output[MAX_PATH] = "";
    char cmd[1024];
    char buffer[1024];
    
    // 获取源代码
    GetWindowText(hEditSource, source, sizeof(source));
    
    // 获取输出文件名
    GetWindowText(hEditOutput, output, sizeof(output));
    if (strlen(output) == 0) strcpy(output, "output.exe");
    
    // 获取平台
    int platform = SendMessage(hComboPlatform, CB_GETCURSEL, 0, 0);
    const char* platformNames[] = {"Windows", "Linux", "macOS"};
    
    // 保存临时文件
    char tempFile[MAX_PATH];
    GetTempPath(MAX_PATH, tempFile);
    strcat(tempFile, "temp.emg");
    
    ofstream out(tempFile);
    out << source;
    out.close();
    
    // 编译
    AddLog("\n========== 开始编译 ==========\n");
    
    char logMsg[256];
    sprintf(logMsg, "目标平台: %s\n", platformNames[platform]);
    AddLog(logMsg);
    sprintf(logMsg, "输出文件: %s\n", output);
    AddLog(logMsg);
    
    // 构建编译命令
    sprintf(cmd, "emerging.exe \"%s\" \"%s\" 2>&1", tempFile, output);
    
    // 执行编译
    FILE* pipe = _popen(cmd, "r");
    if (!pipe) {
        AddLog("错误: 无法启动编译器\n");
        return;
    }
    
    while (fgets(buffer, sizeof(buffer), pipe)) {
        AddLog(buffer);
    }
    int result = _pclose(pipe);
    
    if (result == 0) {
        AddLog("编译成功!\n");
    } else {
        sprintf(logMsg, "编译失败! 错误代码: %d\n", result);
        AddLog(logMsg);
    }
    
    // 删除临时文件
    DeleteFile(tempFile);
}

// 运行程序
void RunProgram(HWND hWnd) {
    char output[MAX_PATH] = "";
    GetWindowText(hEditOutput, output, sizeof(output));
    if (strlen(output) == 0) strcpy(output, "output.exe");
    
    // 检查文件是否存在
    if (GetFileAttributes(output) == INVALID_FILE_ATTRIBUTES) {
        char logMsg[256];
        sprintf(logMsg, "错误: 找不到可执行文件 %s\n请先编译程序\n", output);
        AddLog(logMsg);
        return;
    }
    
    AddLog("\n========== 运行程序 ==========\n");
    
    // 运行程序
    ShellExecute(hWnd, "open", output, NULL, NULL, SW_SHOW);
    
    char logMsg[256];
    sprintf(logMsg, "已启动: %s\n", output);
    AddLog(logMsg);
}

// 添加日志
void AddLog(const char* text) {
    int len = GetWindowTextLength(hEditLog);
    SendMessage(hEditLog, EM_SETSEL, len, len);
    SendMessage(hEditLog, EM_REPLACESEL, FALSE, (LPARAM)text);
}

// 带颜色的日志（简化版）
void AddLogWithColor(const char* text, COLORREF color) {
    AddLog(text);
}

// 设置状态
void SetStatus(const char* text) {
    SetWindowText(hPathDisplay, text);
}
