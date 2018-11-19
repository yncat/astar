//a-star �A���S���Y���ɂ��o�H�T�� by �ɂ�񂿂�
#ifndef __astar__
#define __astar__

#module astar

//�ʂ�邩�ʂ�Ȃ���
#define global ASTAR_INFO_IMPASSABLE 0
#define global ASTAR_INFO_PASSABLE 1

//�A���S���Y���Ŏg��
#define ASTAR_INTERNAL_NONE 0
#define ASTAR_INTERNAL_OPENED 1
#define ASTAR_INTERNAL_CLOSED 2

/*
astar_search int start_x, int start_y, int destination_x, int destination_y, array source_2dmap, var output_var
�X�^�[�g�ʒu����ړI�n�܂ł̍ŒZ�o�H��T�����Aoutput_var �Ɍ��ʂ𕶎���ŕԂ��܂��B
�p�����[�^:
start_x: �X�^�[�g�n�_��X���W
start_y: �X�^�[�g�n�_��Y���W
destination_x: �ړI�n��X���W
destination_y: �ړI�n��Y���W
source_2dmap: �}�b�v�̏����i�[���Ă���z��B�}�b�v�f�[�^��2������int�z��ŁA�ʂ��ꏊ��ASTAR_INFO_PASSABLE�A�ʂ�Ȃ��ꏊ��ASTAR_INFO_IMPASSABLE�Ŏ������f�[�^�B
output_var: ���ʂ��i�[�����ϐ�(�������s�v)
�߂�l: �ړI�n�ɓ��B�\�ł���ꍇ��1�B�ړI�n�ɓ��B�ł��Ȃ��ꍇ��0�B�G���[�̏ꍇ��-1�Boutput_var �ɕԂ���镶����t�H�[�}�b�g�́A�X�^�[�g�ʒu����J�n���āA�o�R������W(x-y)��\n��؂�Ŏ������f�[�^�B���B�s�\����уG���[�̏ꍇ�ɂ́A��̕����񂪏������܂��B
*/

#deffunc astar_search int _px, int _py, int _dx, int _dy, array _source, var out
px=_px:py=_py:dx=_dx:dy=_dy
mx=length(_source)
my=length2(_source)

//�Ȃ���������Ȃ����A�z�����x�R�s�[���Ă��Ȃ��Ɠ����G���[7�ɂȂ����B���Ԃ�Ahsp�� array �w�肪���������l�����Ă��Ȃ��B�����1�����������Ȃ��Ǝv���Ă�Bjust �N�\�B
dim source,mx,my
memcpy source,_source,4*mx*my
//�������m��
dim nodeState,mx,my
dim nodeCostA,mx,my
dim nodeCostH,mx,my
dim nodeScore,mx,my
dim nodeParentx,mx,my
dim nodeParenty,mx,my
sdim openList,10000
openListSize=0
openListNum=0
//�ꎞ�ϐ�
cpx=px
cpy=py
cCost=0
cScore=0
cScoreX=-1
cScoreY=-1
open px,py,-1,-1
parent=stat
//�X�^�[�g�n�_���I�[�v��
counter=0
nopath=0
repeat//�T���J�n
counter++
if cpx=dx: if cpy=dy:break//�ړI�n�ɒ�������I������
if openListNum=0:nopath=1:break//�I�[�v�����X�g�������Ȃ��̂ŁA�ǂ�����Ă��s���Ȃ�
//����4�����B8�����ɑΉ�����������΁A���̉��ɂ���I�[�v���̒�`��ǉ����āA�΂ߏ�Ƃ����I�[�v������悤�ɕύX����B
if cpx!0:open cpx-1,cpy,cpx,cpy//�����I�[�v��
if cpx!mx-1:open cpx+1,cpy,cpx,cpy//�E���I�[�v��
if cpy!0:open cpx,cpy-1,cpx,cpy//�����I�[�v��
if cpy!my-1:open cpx,cpy+1,cpx,cpy//����I�[�v��
close parent//�e�m�[�h�͕���
//�I�[�v�����X�g����A�X�R�A�������Ƃ����������̂�T��
cScore=-1//�l�͖��ݒ�
repeat openListNum
x=lpeek(openList,cnt*8)
y=lpeek(openList,(cnt*8)+4)
if cScore=-1 or nodeScore(x,y)<cScore:{//��菬�����R�X�g�ōs����o�H�Ȃ̂ŁA�������ɍX�V
cScore=nodeScore(x,y)
cScoreX=x
cScoreY=y
}
loop//�T������
//�ŒZ�R�X�g���ƕ��������ꏊ�ɃJ�[�\�����ړ�������B���͂���������͂��I�[�v�����Ă������ƂɂȂ�B
cpx=cScoreX
cpy=cScoreY
parent=getOpenList(cpx,cpy)//���A�e�m�[�h�̓I�[�v������Ă���̂ŁA���W����Ǘ��ԍ����v�Z���Ă��ē����
loop
//�o�H�T���̓������o��
sdim tmp,10000
if nopath:{//�s���Ȃ�����
tmp=""
}else{//�o�H���������̂ŁA���W�����Ă���
tmp=""+dx+"-"+dy+","
repeat//�e�m�[�h�����ǂ葱����A����open�֐������������Z�b�g���Ă���Ă���
prx=nodeParentx(cpx,cpy)
pry=nodeParenty(cpx,cpy)
//�e�m�[�h�ɃJ�[�\���ړ�
cpx=prx
cpy=pry
tmp+=""+prx+"-"+pry+","
if prx=px:if pry=py:break//�X�^�[�g�܂Ŗ߂��Ă����̂Ŕ�����
loop
//�ړI�n����e�����ǂ��Ă��ăX�^�[�g�܂ŗ����̂ŁA���̃��X�g�͋t�ɂ���K�v������
split tmp,",",tmp2
sdim tmp,10000
counter=length(tmp2)-2
repeat counter+1
tmp+=tmp2(counter)+"\n"
counter--
loop
sdim tmp2,0
}//�s�������s���Ȃ��������A�ǂ���ɂ��������ꂽ
sdim out,strlen(tmp)+1
out=tmp
sdim tmp,0
return nopath|1

//�������牺�͓����Ŏg���֐�
#deffunc open int openx, int openy, int parentx, int parenty//�e����ׂ̃m�[�h���I�[�v������
if nodeState(openx,openy)!ASTAR_INTERNAL_NONE:return//�ߋ��ɃI�[�v�����Ă���Ƃ���͍ăI�[�v���ł��Ȃ����A���I�[�v�����Ă�Ƃ�����I�[�v���ł��Ȃ�
if source(openx,openy)=ASTAR_INFO_IMPASSABLE:return//�ʂ�Ȃ��Ƃ���̓I�[�v���ł��Ȃ�
nodeState(openx,openy)=ASTAR_INTERNAL_OPENED
//���R�X�g�Ɛ���R�X�g���v�Z
nodeCostA(openx,openy)=abs(px-openx)+abs(py-openy)
nodeCostH(openx,openy)=abs(openx-dx)+abs(openy-dy)
//��̃R�X�g�����ƂɃX�R�A���v�Z
nodeScore(openx,openy)=nodeCostA(openx,openy)+nodeCostH(openx,openy)
if parentx!-1 and parenty!-1:nodeParentx(openx,openy)=parentx:nodeParenty(openx,openy)=parenty//�e������΁A�e�m�[�h�̏ꏊ���i�[
//�I�[�v�����X�g�ɏ�������
lpoke openList,openListSize,openx
lpoke openList,openListSize+4,openy
openListSize+=8
openListNum++
return openListSize-8

#deffunc close int closeNum//�w�肳�ꂽ�I�t�Z�b�g�̃m�[�h���N���[�Y���A�I�[�v�����X�g����폜����
closex=lpeek(openList,closeNum)
closey=lpeek(openList,closeNum+4)
nodeState(closex,closey)=ASTAR_INTERNAL_CLOSED
memcpy openList,openList,10000-closeNum-8,closeNum,closeNum+8//�������̈�����炵�ď㏑��
openListNum--
openListSize-=8
return
#defcfunc getOpenList int getx, int gety//���W����A�I�[�v�����X�g��̃I�t�Z�b�g���v�Z����
found=-1
repeat openListNum
if lpeek(openList,cnt*8)=getx:if lpeek(openList,(cnt*8)+4)=gety:found=cnt*8:break
loop
return found

#global

#endif