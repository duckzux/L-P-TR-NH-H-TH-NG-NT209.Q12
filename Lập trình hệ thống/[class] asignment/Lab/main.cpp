#include <stdio.h>

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
	return ~x + 1;
}

// 1.3
int getByte(int x, int n)
{
	// n << 3 = n * 8 => để dịch 1 byte -> dịch bit 8 lần
	// x >> (n << 3) => dịch phải x đưa byte thứ n về vị trí thấp nhất
	// & 0xFF = giữ lại byte cuối (dùng mask)
	return (x >> (n << 3) & 0x000000FF);
}

// 1.4
int getnbit(int x, int n){
    //(1 << n) => tạo mask 1000...0 có n bit 0 bên phải
    int mask = (1 << n) + (~1 + 1);//tạo mask để lấy n bit 1, tương tự (1<<n)-1 (ví dụ n=3 0000 1000 - 1 => 0000 0111)
    return x & mask;// giữ lại n bit bên phải nhất của xx
}

// 1.5
//Cách 1
int mulpw2(int x, int n)
{
	int neg = n >> 31; //mask lấy giá trị bit bên trái ngoài cùng, nếu n âm thì neg = -1 (0xFFFFFFFF), ngược lại = 0
	int abs_s = (n ^  neg) + (~neg+1); //lấy trị tuyệt đối của n, nếu âm thì lấy bù 2, nếu dương thì lấy bình thường
	int shift_left = x << abs_s; // nếu như x dương thì dịch trái, mũ n như bình thường
	int shift_right = x >> abs_s; //nếu như x âm thì dịch phải, mũ -n
	return (neg & shift_right) | (~neg & shift_left);
	//Dùng toán tử & với 0xFFFFFFFF (neg hoặc ~neg) cho ra kết quả ứng với điều kiện của neg
	//Toán tử | để chọn trường hợp
}

//1.5 Cách 2
// int mulpw2(int x, int n) {
//     unsigned abs_s = (n ^ (n >> 31)) + (~(n >> 31) + 1); // Lấy giá trị tuyệt đối
//     //Nếu n >= 0 thì n >> 31 = 0 nên có abs_s = (n ^ 0) - 0 = n , bằng chính nó
//     //Nếu n < 0 thì n n >> 31 = -1 nên có abs_s = ~n + 1 = (n ^ -1) - (-1)
//     int shift_left = x << abs_s;// nếu như x dương thì dịch trái, mũ n như bình thường
//     int shift_right = x >> abs_s;//nếu như x âm thì dịch phải, mũ -n tương đương với việc chia cho 2 mũ -nn
//     return (shift_left & ~(n >> 31)) | (shift_right & (n >> 31));
// }

// 2.1
int isSameSign(int x, int y)
{
	int diff = (x >> 31) ^ (y >> 31); // 0 nếu cùng dấu, -1 nếu khác dấu
	return (diff ^ 1) & 1;            // 0/1: 1 nếu cùng dấu, 0 nếu khác
	// XOR để đổi 0x0 -> 0xFFFFFFFF, 0xFFFFFFFF -> 0x00000000, &1 để lấy bit cuối cùng
}

// 2.2
int is8x(int x)
{
	//Một số chia hết cho 8 <=> 3 bit cuối là 0
	//Do đó, cần tạo 1 mask để lấy 3 bit cuối , là mask 0x7
	int three_bit = x & 0x7;
	//Sau đó kiểm tra xem 3 bit cuối có bằng 0 hay không
	//Nếu bằng 0 thì trả về 1
	//Dựa vào tính chất chỉ có 0 mới bằng chính nó bù 2 (0 == -0) thì khi 0 OR với chính nó sẽ ra 0x0, có bit dấu là 0
	//Các số còn lại thì khi OR với bù 2 của chính nó thì sẽ ra 1 số có bit dấu là 1 (1.....). VD số 5 (0000....0101) và -5 (1111....1011)
	int check_zero = three_bit | (~three_bit + 1);
	//Sau đó, dời phải 31 bit, nếu bit dấu là 0 thì cho kết quả là 0 (0x0), bit dấu là 1 thì cho kết quả là -1 (0xFFFFFFFF)
	//+1 vào sẽ cho ra kết quả là 1 (nếu 3 bit dấu là 0) và 0 (trong các TH còn lại)
	return (check_zero >> 31) + 1;
}

// 2.3
int isPositive(int x)
{
	//Cách 1:
	//x > 0: !(x >> 31) là 1 và !x là 0.
	//x = 0 : !(x >> 31) là 1 và !x là 1.
	//x < 0 : !(x >> 31) là 0 và !x là 0.
	//Ket qua mong muon la 1 khi !(x >> 31) là 1 và !x là 0, toan tu can su dung là ^ xor
	// return (!(x >> 31)) ^ (!x);

	//Cách 2:
	int sign = (x >> 31) & 1;
	// Nếu x >= 0 ->0 (0000...0000), x < 0 -> -1 (1111...1111)
	// &1 để lấy bit dấu: 1 nếu âm, 0 nếu >=0
	int nonNegative = sign ^ 1;// kiểm tra số không âm: đảo bit -> 1 nếu >=0, 0 nếu âm
	//Dựa vào tính chất chỉ có 0 mới bằng chính nó bù 2 (0 == -0) thì khi 0 OR với chính nó sẽ ra 0x0, có bit dấu là 0
	//Các số còn lại thì khi OR với bù 2 của chính nó thì sẽ ra 1 số có bit dấu là 1 (1.....). VD số 5 (0000....0101) và -5 (1111....1011)
	//Sau đó, dời phải 31 bit, nếu bit dấu là 0 thì cho kết quả là 0 (0x0), bit dấu là 1 thì cho kết quả là -1 (0xFFFFFFFF)
	int check = (x | (~x + 1)) >> 31;
	int isZero = (check & 1) ^ 1; // lấy bit cuối rồi đảo bit để kiểm tra số có bằng 0: 1 nếu x == 0, 0 nếu x != 0
	//Dùng XOR kiểm tra đồng thời cả điều kiện không âm và khác 0: x > 0: 1^0 -> 1;		x = 0: 1^1 -> 0;	x < 0: 0^0 -> 0
	return nonNegative ^ isZero;
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
	return sign & 1;
	//dùng (sign & 1) để kiểm tra bit cuối -> trả kết quả âm = 1, dương = 0
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
