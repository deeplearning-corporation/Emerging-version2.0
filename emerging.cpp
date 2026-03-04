/**
 * Emerging 2.0 编译器 - 控制台版本
 * 直接从命令行编译 .emg 文件
 * 
 * 编译命令:
 * g++ -o emerging.exe emerging.cpp -O2
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <cctype>
#include <cstdint>
#include <algorithm>
#include <cstring>
#include <ctime>
using namespace std;

// ... 原有代码保持不变 ...

int main(int argc, char* argv[]) {
    if (argc != 3) {
        cout << "Emerging 2.0 Compiler" << endl;
        cout << "Usage: emerging input.emg output.exe" << endl;
        return 1;
    }
    
    ifstream in(argv[1]);
    if (!in) {
        cerr << "Cannot open input file: " << argv[1] << endl;
        return 1;
    }
    
    string source((istreambuf_iterator<char>(in)), istreambuf_iterator<char>());
    in.close();
    
    // ... 编译过程 ...
    
    cout << "Compilation successful: " << argv[2] << endl;
    return 0;
}
