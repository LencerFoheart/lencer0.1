/*
 * Small/tools/build.c
 *
 * (C) 2012-2013 Yafei Zheng
 * V0.0 2012-12-7 19:53:15
 * V0.1 2013-01-30 19:44:27
 *
 * Email: e9999e@163.com, QQ: 1039332004
 */

/*
 * �˳��������windows(VC6.0)��ʹ�ã�Ҳ������Unix/Linux(GCC 4.6.3)��ʹ�á�
 * �˳���ȥ����ص�MINIXͷ��GCCͷ����OS��ģ����װ��һ�顣
 */

#include <stdio.h>
#include <string.h>

#define BUFF_SIZE 1024			// �������ֽ���

#define OFFSET_BOOT 32			// ���ļ���ʼ����ƫ����(�ֽ���),����ȥ��boot.s��as86����֮���MINIXͷ(32B)
#define OFFSET_SYSTEM 0x1000	// ȥ��systemģ���0x1000B��GCCͷ����Linux-0.11�У���1024B����Ϊ��ʱ��GCC��
								// �ɵĿ�ִ���ļ��� a.out ��ʽ�ģ������õ�GCC(gcc 4.6.3 for Start OS)���ɵ�
								// �� ELF ��ʽ������ELF�ļ�ͷ����ο�ELF������ݡ�

int main(void)
{
	char buff[BUFF_SIZE] = {0};
	FILE *fp_system = NULL, *fp_boot = NULL, *fp_Image = NULL;
	int count = 0, size_os = 0;

	if(! ((fp_system=fopen("tools/system","rb")) && (fp_boot=fopen("boot/boot","rb")) && (fp_Image=fopen("Image","wb"))))
	{
		printf("Error: can't open some file!!!\n");
		printf("\npress Enter to exit...");
		getchar();
		return -1;
	}

	fseek(fp_boot,OFFSET_BOOT,SEEK_SET);
	fseek(fp_system,OFFSET_SYSTEM,SEEK_SET);

	for(; (count=fread(buff,1,sizeof(buff),fp_boot))>0; size_os+=count,fwrite(buff,count,1,fp_Image)) {}
	fclose(fp_boot);
	for(; (count=fread(buff,1,sizeof(buff),fp_system))>0; size_os+=count,fwrite(buff,count,1,fp_Image)) {}
	fclose(fp_system);
	fclose(fp_Image);
	
	printf("===OK!\nSize of OS is %d Bytes.\n",size_os);

	printf("build exit.\n\n");
	return 0;
}
