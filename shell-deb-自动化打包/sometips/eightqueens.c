#include<iostream>
using namespace std;
static int gEightQueen[8] = { 0 }, gCount = 0;
void print()//输出每一种情况下棋盘中皇后的摆放情况
{
    for (int i = 0; i < 8; i++)
    {   
        int inner;
        for (inner = 0; inner < gEightQueen[i]; inner++)
            cout << "0";
            cout <<"#";
        for (inner = gEightQueen[i] + 1; inner < 8; inner++)
            cout << "0";
        cout << endl;
    }
    cout << "==========================\n";
}
int check_pos_valid(int loop, int value)//检查是否存在有多个皇后在同一行/列/对角线的情况
{
    int index;
    int data;
    for (index = 0; index < loop; index++)
    {
        data = gEightQueen[index];
        if (value == data)
            return 0;
        if ((index + data) == (loop + value))
            return 0;
        if ((index - data) == (loop - value))
            return 0;
    }
    return 1;
}
void eight_queen(int index)
{
    int loop;
    for (loop = 0; loop < 8; loop++)
    {
        if (check_pos_valid(index, loop))
        {
            gEightQueen[index] = loop;
            if (7 == index)
            {
                gCount++, print();
                gEightQueen[index] = 0;
                return;
            }
            eight_queen(index + 1);
            gEightQueen[index] = 0;
        }
    }
}
int main(int argc, char*argv[])
{
    eight_queen(0);
    cout << "total=" << gCount << endl;
    return 0;
}
