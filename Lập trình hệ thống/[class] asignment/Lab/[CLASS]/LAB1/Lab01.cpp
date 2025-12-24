#include <stdio.h>
#include <iostream>
using namespace std;

void PrintBits(unsigned int x)
{
	int i;
	for (i = 8 * sizeof(x) - 1; i >= 0; i--)
	{
		(x & (1 << i)) ? putchar('1') : putchar('0');
	}
	printf("\n");
}
void PrintBitsOfByte(unsigned int x)
{
	int i;
	for (i = 7; i >= 0; i--)
	{
		(x & (1 << i)) ? putchar('1') : putchar('0');
	}
	printf("\n");
}

// 1.1
int bitAnd(int x, int y)
{
	// ~(x & y) = ~x | ~y (OR)
	// ~(~x | ~y) = ~~(x & y) = (x & y)(De Morgan) 
	return ~(~x | ~y); 
}

// 1.2
int negative(int x)
{
	// Lấy bù 2: ~x + 1 => giá trị -x (nghịch đảo bit và cộng 1)
	return ~x+1;
}

// 1.3
int getByte(int x, int n)
{
	// n << 3 = n * 8 => để dịch 8 bit = 1 byte
	// x >> (n << 3) => dịch phải x để đưa byte thứ n về cuối
	// & 0xFF = giữ lại 8 bit cuối (dùng mask)
	return (x >> (n<<3) & 0x000000FF);
}

// 1.4
int getnbit(int x, int n)
{

	// (1 << n) => tạo mask 1000...0 có n bit 0 bên phải
	// (~0) = tất cả bit 1
	// (1 << n) + (~0) = (1<<n)-1 (ví dụ n=3 => 0000 0111) => lấy mask n bit 1
	// x & mask => giữ lại n bit bên phải nhất của x
	return x & ((1 << n) + (~0));
}


// 1.5
int mulpw2(int x, int n)
{
	// if(n >= 0) 
	//     return x >> n;
	// else
	//     return x >> (-n);

	int neg = n >> 31; //nếu n âm thì neg = -1, ngược lại thì neg = 0
	int abs_s = (n ^ neg) - neg; //lấy trị tuyệt đối của nNice
	int shift_left = x << abs_s; // nếu như x dương thì dịch trái, mũ n như bình thường
	int shift_right = x >> abs_s; //nếu như x âm thì dịch phải,
	return (neg & shift_right) | (~neg & shift_left);
}



// 2.1
int isSameSign(int x, int y)
{
	int signx = x >> 31,
		signy = y >> 31;
	//Dung phep dich phai 31 bit de lay dau cu so 32 bit
	//Dung phep XOR de so sanh, 
	//phep XOR cho ra 0 neu 2 gia tri (o day la bit dau) giong nhau, do do dung them ! de dao nguoc kq
	return !(signx ^ signy);
}

// 2.2
int is8x(int x)
{
	//Mot so chia het cho 8 <=> 3 bit cuoi la 0
	//Do do, can tao 1 mask de kiem tra 3 bit cuoi, la mask 0x7 (bieu dien nhi phan la 0000 0111)
	//Su dung phep toan & giua x va mask, neu ket qua bang 0 => 3 bit cuoi la 0 <=> chia het cho 8
	return !(x & 0x7);
}

// 2.3
int isPositive(int x)
{
	//x > 0: !(x >> 31) là 1 và !x là 0.
	//x = 0 : !(x >> 31) là 1 và !x là 1.
	//x < 0 : !(x >> 31) là 0 và !x là 0.
	//Ket qua mong muon la 1 khi !(x >> 31) là 1 và !x là 0.
	return (!(x >> 31)) ^ (!x);
}

// 2.4
int isLess2n(int x, int y)
{
	// lấy mũ: pow2n = 2^y
	int pow2n = 1 << y;
	// phép trừ để kiểm tra: check = x - pow2n (dùng bù 2)
	int check = x + (~pow2n + 1);
	// Lấy bit dấu => 1 nếu âm, 0 nếu dương
	int sign = check >> 31;
	// !! => ép int về boolean 0 hoặc 1
	// !đầu:  1 thành 0,  0 thành 1.
	// !  hai : đảo lại một lần nữa, đưa kết quả về 1 hoặc 0.
	return !!sign;
}

int main()
{
	int score = 0;
	printf("Your evaluation result:");
	printf("\n1.1 bitAnd");
	if (bitAnd(3, -9) == (3 & -9))
	{
		printf("\tPass.");
		score += 1;
	}
	else
		printf("\tFailed.");

	printf("\n1.2 negative");
	if (negative(0) == 0 && negative(9) == -9 && negative(-5) == 5)
	{
		printf("\tPass.");
		score += 1;
	}
	else
		printf("\tFailed.");

	//1.3
	printf("\n1.3 getByte");
	if (getByte(8, 0) == 8 && getByte(0x11223344, 1) == 0x33)
	{
		printf("\tPass.");
		score += 2;
	}
	else
		printf("\tFailed.");

	printf("\n1.4 getnbit");
	if (getnbit(0, 0) == 0 && getnbit(31, 3) == 7 && getnbit(16, 4) == 0)
	{
		printf("\tPass.");
		score += 3;
	}
	else
		printf("\tFailed.");
	//1.5
	printf("\n1.5 mulpw2");
	if (mulpw2(10, -1) == 5 && mulpw2(15, -2) == 3 && mulpw2(32, -4) == 2)
	{
		if (mulpw2(10, 1) == 20 && mulpw2(50, 2) == 200)
		{
			printf("\tAdvanced Pass.");
			score += 4;
		}
		else
		{
			printf("\tPass.");
			score += 3;
		}
	}
	else
		printf("\tFailed.");

	printf("\n2.1 isSameSign");
	if (isSameSign(4, 2) == 1 && isSameSign(13, -4) == 0 && isSameSign(0, 10) == 1)
	{
		printf("\tPass.");
		score += 2;
	}
	else
		printf("\tFailed.");

	printf("\n2.2 is8x");
	if (is8x(16) == 1 && is8x(3) == 0 && is8x(0) == 1)
	{
		printf("\tPass.");
		score += 2;
	}
	else
		printf("\tFailed.");

	printf("\n2.3 isPositive");
	if (isPositive(10) == 1 && isPositive(-5) == 0 && isPositive(0) == 0)
	{
		printf("\tPass.");
		score += 3;
	}
	else
		printf("\tFailed.");

	printf("\n2.4 isLess2n");
	if (isLess2n(12, 4) == 1 && isLess2n(8, 3) == 0 && isLess2n(15, 2) == 0)
	{
		printf("\tPass.");
		score += 3;
	}
	else
		printf("\tFailed.");

	printf("\n--- FINAL RESULT ---");
	printf("\nScore: %.1f", (float)score / 2);
	if (score < 5)
		printf("\nTrouble when solving these problems? Contact your instructor to get some hints :)");
	else
	{
		if (score < 8)
			printf("\nNice work. But try harder.");
		else
		{
			if (score >= 10)
				printf("\nExcellent. We found a master in bit-wise operations :D");
			else
				printf("\nYou're almost there. Think more carefully in failed problems.");
		}
	}

	printf("\n\n\n");
}
